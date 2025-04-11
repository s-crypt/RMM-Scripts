# Check all sources for all installed appliocations
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
    Select-Object DisplayName, DisplayVersion, InstallLocation
}

# Get programs installed from Microsoft Store
$storeApps = Get-AppxPackage |
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
    $allPrograms | Sort-Object -Property DisplayName | Format-Table -AutoSize
    #Get a specific value from the table
    #Write-Output $allPrograms[0].DisplayName
}