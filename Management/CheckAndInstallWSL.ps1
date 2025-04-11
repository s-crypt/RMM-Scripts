# From: https://euc365.com/post/deploy-windows-subsystem-for-linux/

# Check install status
if (Get-WmiObject -Class Win32_OptionalFeature | Where-Object { ($_.Name -Match "Microsoft-Windows-Subsystem-Linux") -and ($_.InstallState -eq 1) }) {
    $installed = $true
}
else {
    $installed = $false
}

# Perform an action if WSL is installed, not installed, or somehow another
switch ($installed) {
    $true {
        Write-Host "WSL is installed. Checking for updates."
        wsl.exe --update
    }
    $false {
        Write-Host "WSL is not installed. Installing."
        Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
    }
    Default {
        Write-Host "Somehow you have gotten a third option: $installed"
    }
}