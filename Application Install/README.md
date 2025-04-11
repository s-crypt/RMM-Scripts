# Installing Software via Scripting

The following scripts are used to check and install software remotely using PowerShell scripts

| Name | Description |
| --- | --- |
| [Check Win App Installation](./CheckWinAppInstallation.ps1) | Check for standard 32/64bit and Microsoft Store applications |
| [Check Win App Installation ConnectWise](./CheckWinAppInstallationConnectWise.ps1) | Same as above but for use in ConnectWise Script Editor |
| [Choco Install Upgrade](./ChocoInstallUpgrade.ps1) | Install a chocolatey package and update if configured |
| [Chocolatey Management](./ChocolateyManagement.ps1) | Install chocolatey if it isn't and use enhanced error codes |
| [Install CaptureClient](./InstallCaptureClient.ps1) | Install SonicWall Capture Client with the URL and token for use with ConnectWise variables |
| [Winget Install Application](./WingetInstallApplication.ps1) | Install an application using Winget if not installed |W