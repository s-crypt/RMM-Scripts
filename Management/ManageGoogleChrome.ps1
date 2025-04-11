# Define the Google Chrome enrollment token
$token = "@token@"

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

Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome' -Property 'CloudManagementEnrollmentToken' -Type String -Value $token