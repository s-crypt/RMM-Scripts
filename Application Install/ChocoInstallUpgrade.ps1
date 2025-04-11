# Regex string to search for installed application
$SearchString = ""
# Chcolatey package to install
$package = ""
# Use $true to install updates. Otherwise, updates will not be installed but logged.
$update = $false
# Use $true to disable package updates through chocolatey, like if the application has an auto-updater or a specific version should be installed.
$pin = $false

# ===============================================================================

function Invoke-Chocolatey {
    # Check if chocolatey is installed

    if (-not(Test-Path -Path "C:\ProgramData\chocolatey\bin\choco.exe")) {
        throw "ERROR: Chocolatey is not installed."
    }
    else {
        $choco = "C:\ProgramData\chocolatey\bin\choco.exe"
    }

    # Check if package is installed
    if (& $choco list --limit-output --exact $package) {
        Write-Host "$package is installed."
        # If opted for updates, check and install any package updates
        if (($update -eq $true) -and ($pin -eq $false)) {
            Write-Host "Checking for package updates."
            & $choco upgrade $package --yes
        }
    }
    else {
        Write-Host "$package is not installed. Installing"
        & $choco install $package --yes
        # If opted to pin package, pin it
        if ($pin = $true) {
            Write-Host "Pinning package $package"
            & $choco pin add --name="$package" --yes
        }
    }
}

function Test-InstalledApplication {

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


# =================================================================================

if ((Test-InstalledApplication -SearchString $SearchString) -eq $false) {
    Invoke-Chocolatey
}