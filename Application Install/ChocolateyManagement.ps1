$choco = "C:\ProgramData\chocolatey\bin\choco.exe"

function Invoke-ChocolateyManagement {
    
    try {
        # If chocolatey does not output a version, it is not installed
        if ((& $choco --version)) {
            Write-Host "Chocolatey Version $testchoco is already installed. Checking for updates."
            & $choco upgrade chocolatey --yes
        }
    }

    # If chocolatey is not found, powershell throws an error. In this case, install chocolatey.
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "Seems Chocolatey is not installed, installing now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }

}

function Set-ChocolateyFeatures {
    # Test if the correct features are enabled
    if ((& $choco feature get --name="UseEnhancedExitCodes" --limit-output) -eq "Disabled") {
        Write-Host "Enabling enhanced exit codes"
        & $choco feature enable --name="UseEnhancedExitCodes"
    }
}

Invoke-ChocolateyManagement
Set-ChocolateyFeatures