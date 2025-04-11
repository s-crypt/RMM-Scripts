# ============Edit these variables============
# What application to search for
$Search = "(Microsoft Teams$)|(MSTeams)"
# The winget package to install
$ProgramToInstall = "Microsoft.Teams"
# Add custom installer flags if necessary
$WingetCustomFlags = ""

function Test-InstalledApplication {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$SearchString
    )

    # Check all sources for an installed application using a search key
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    $programs = $paths | 
    ForEach-Object {
        # Get the current path, ignore if it is invalid
        Get-ItemProperty -Path "$_\*" -ErrorAction SilentlyContinue |
        Where-Object { ($_.DisplayName -match $SearchString) } |
        Select-Object DisplayName, DisplayVersion, InstallLocation
    }

    # Get programs installed from Microsoft Store
    $storeApps = Get-AppxPackage | Where-Object { ($_.Name -match $SearchString) } | 
    # Rename variables for the table
    Select-Object @{Name = "DisplayName"; Expression = { $_.Name } }, 
    @{Name = "DisplayVersion"; Expression = { $_.Version } },
    InstallLocation

    # Combine results
    $allPrograms = @()
    $allPrograms += $programs
    $allPrograms += $storeApps

    # Display results in a table if not empty
    if ($null -ne $allPrograms[0].DisplayName) {
        Write-Host ($allPrograms | Sort-Object -Property DisplayName | Format-Table -AutoSize | Out-String)
        return $true
    }
    else {
        Write-Host "Application not found"
        return $false
    }
}

function Get-WingetExe {
    
    $WingetCmd = Get-Command winget.exe -ErrorAction SilentlyContinue

    if ($WingetCmd) {
        $winget = $WingetCmd.Source
    }
    elseif (Test-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe") {
        $winget = Resolve-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe" | Select-Object -ExpandProperty Path
    }
    elseif (Test-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe") {
        $winget = Resolve-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" | Select-Object -ExpandProperty Path
    }
    else {
        throw "Winget not installed"
    }
    Write-Host "Winget location:" $winget
    return $winget
}

function Invoke-WingetInstall {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$PackageName
        ,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$CustomFlags
        ,
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$wingetexe
    )
    
    # Check if there are custom flags
    if ($CustomFlags -ne $null) {
        Write-Host "Custom Flags detected: $CustomFlags"
        & $wingetexe install --id $PackageName --silent $CustomFlags --accept-source-agreements --accept-package-agreements --verbose
    }
    else {
        Write-Host "No Custom Flags detected"
        & $wingetexe install --id $PackageName --silent --accept-source-agreements --accept-package-agreements --verbose
    }
}

# ================================================================

# If the application does not exist, install it
if ((Test-InstalledApplication -SearchString $Search) -eq $false) {
    Invoke-WingetInstall -PackageName $ProgramToInstall -CustomFlags $WingetCustomFlags -WingetExe (Get-WingetExe)
}
else {
    Write-Host "No action necessary"
}