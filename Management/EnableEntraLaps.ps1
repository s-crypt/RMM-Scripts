# To find more information on settings, visit https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-management-policy-settings#windows-laps-group-policy
# This script will set the local device's registry values in LAPS CSP (the highest Priority) to enroll in Entra LAPS
# Certain features are only available on Windows 11 24H2 and Windows Server 2025 or later. See the link for details

# If there is an existing local admin account, specify the name here.
# Set to $false to manage the built in administrator account
$LocalAdminUsername = 'Local Admin'
# Set the number of days before the password is rotated
$PasswordAge = 30
# Use a passphrase instead of random characters?
$Passphrase = 1
# Specify the passphrase length by the number of words
$PassphraseLength = 6
# If Passphrase is set to false, set the character length of the password from 8-64
$PasswordLength = 14
# Set the Post Autentication Action to be preformed after the LAPS account has been logged in on Win11 24H2+ and Win Server 2022+. https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-management-policy-settings#postauthenticationactions
$PostAuthAct = 1
# Set the delay in hours (0-24) for the Post Authentication Action. Set to 0 to disable the action. https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-management-policy-settings#postauthenticationactions
$PostAuthDelay = 0

# Enable Automatic Account Management? Settings below are irrelevent if not enabled
$AAM = 0
# Create new management account [1] or use the built in administrator account [0]
$AAMTarget = 1
# Set the name or prefix of the managed account.
$AAMName = 'WLapsAdmin'
# Enable the automatically managed account?
$AAMEnabled = 0
# Randomize the account name every time the password is rotated?
$AAMRandom = 0


Function Invoke-RegistryCheckAndSet {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Property
        ,
        [Parameter(Position = 2, Mandatory = $true)]
        $Type
        ,
        [Parameter(Position = 3, Mandatory = $false)]
        $Value
    )
    try {
        if (((Test-Path -Path $Path) -contains $Property) -and ((Get-ItemProperty -Path $Path).$Property -match $Value)) {
            Write-Host "Entry `"$Property`" exists and is correct."
        }
        elseif (((Test-Path -Path $Path) -contains $Property) -and (-not (Get-ItemProperty -Path $Path).$Property -match $Value)) {
            Write-Host "Registry entry `"$Property`" exists, but is not the correct value. Setting correct value."
            Set-ItemProperty -Path ($Path).$Property = $Value
        }
        else {
            Write-Host "Entry `"$Property`" missing. Adding to registry."
            $NewRegEntry = @{
                Path         = $Path
                Name         = $Property
                PropertyType = $Type
                Value        = $Value
            }
            if (Test-Path -Path $Path) {
                Write-Host "Key `"$Path`" exists, adding registry entry `"$Property`"."
            }
            else {
                Write-Host "Key `"$Path`" does not exist. Creating Key and registry entry `"$Property`""
                New-Item -Path $Path -Force | Out-Null
            }
            # New-ItemProperty -Path $Path -Name $Property -PropertyType $Type -Value $Value
            New-ItemProperty @NewRegEntry -Force | Out-Null
        }
    }
    catch {
        Write-Host "*************************"
        Write-Host "There was an error setting the registry value:"
        Write-Host $_
        Write-Host "*************************"
    }
}

$hr = "--------------------"

# Read-Host -Prompt "Ensure you are running the script as an Administrator. Press any key to run."
Write-Host "`nEnabling Entra LAPS via Local Group Policy"


Write-Host "`nSetting Backup Directory to Entra`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'BackupDirectory' -Type DWord -Value 1

if (($LocalAdminUsername -ne $false) -and ($AAM -eq 0)) {
    Write-Host "`nDefining Name of Local Admin to $LocalAdminUsername`n$hr"
    Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'AdministratorAccountName' -Type String -Value $LocalAdminUsername

}
if ($AAM -eq 1) {

    Write-Host "`nSetting account managment to $AAM`n$hr"
    Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'AutomaticAccountManagementTarget' -Type String -Value $AAMTarget

    if ($AAMTarget -eq 1) {
        
        Write-Host "`nSetting the name of the managed account to $AAMName`n$hr"
        Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'AutomaticAccountManagementNameOrPrefix' -Type String -Value $AAMName
    }
    if ($AAMRandom -eq 1) {
        Write-Host "`nEnabling AAM account name randomization`n$hr"
        Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'AutomaticAccountManagementRandomizeName' -Type DWord -Value $AAMRandom
    }
    if ($AAMEnabled -eq 1) {
        Write-Host "`nEnabling managed account`n$hr"
        Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'AutomaticAccountManagementEnableAccount' -Type DWord -Value $AAMEnabled
    }
}

if ($Passphrase -eq 1) {
    Write-Host "`nEnabling passphrase as password`n$hr"
    Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PasswordComplexity' -Type DWord -Value 6

    Write-Host "`nSetting passphrase length to $PassphraseLength`n$hr"
    Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PassphraseLength' -Type DWord -Value $PassphraseLength
}
if ($Passphrase -eq 0) {
    Write-Host "`nSetting password type to random characters`n$hr"
    Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PasswordComplexity' -Type DWord -Value 5

    Write-Host "`nSetting password length to $PasswordLength`n$hr"
    Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PasswordComplexity' -Type DWord -Value $PasswordLength

}

Write-Host "`nSetting managed local account password max age to $PasswordAge`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PasswordAgeDays' -Type DWord -Value $PasswordAge

Write-Host "`nSetting Post Authentication Delay to $PostAuthDelay"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PostAuthenticationResetDelay' -Type DWord -Value $PostAuthDelay

Write-Host "`nSetting Post Authentication Action to $PostAuthAct"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Policies\LAPS' -Property 'PostAuthenticationActions' -Type DWord -Value $PostAuthAct
