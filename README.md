# Useful Powershell scripts

These are some PowerShell scripts that I made and use with RMM tools. Some are ConnectWise specific but can be used with others by changing `@variables@`.

## Application Install

See [InstallationMethods.md](./Application%20Install/README.md)

## Bloatware Removal

See [DebloatInformation.md](./Bloatware%20Removal/README.md)

## Management

Scripts for computer and OS management.

| Script                | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| Check and Install WSL | Checks if WSL is enabled, and installs/enables it if not.    |
| Enable Entra LAPS     | Enable and configure LAPS to use Entra via local policy      |
| Enable Secure DNS     | Set DNS over HTTPS servers on all network interfaces*        |
| Manage Google Chrome  | Installs the Chrome Browser Management Token in the registry |

*currently native DoH cannot be forced programatically, but still sets DNS servers and URLs

## Misc

Scripts that don't really fit into a category.

| Script        |   Description                                                                                             |
| ------------- | --------------------------------------------------------------------------------------------------------- |
| RDP Shortcuts | Using a list of addresses and names, add RDP shortcuts to the desired location (like all users' desktops) |
