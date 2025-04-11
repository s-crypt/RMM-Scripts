# Turn off Windows "Features" - TurnOffWindowsFeatures.ps1
Windows now has a lot of bloatware features that are not used and are not indended in a business environment (or even a personal environment). Here is a list of things that the script changes/disables through registry values:
- Disable search highlights
- Enable file extensions in Explorer
- Disable Bing search in Windows search
- Disable local account "security" questions
- Set telemetry level to basic
- Disable Windows "widgets"
- *Disable windows spotlight
- Disable "app suggestions" (Ads)
- Disable "chat" in taskbar
- Disable Windows Copilot
- Shrink search bar to Icon and Label
- Disable Copilot Recall
- Disable Windows "Suggestions"
  - Windows welcome experience
  - Suggestions in start
  - Get tips, tricks, and suggestions more as you use windows
  - Show suggested content in the settings app
  - Show account notifications in the settings app
  - Suggest wats to finish setting up my device to get the most out of Windows
  - Automatic installation of suggested apps
  - Show suggestions for connecting mobile device with Windows
  - *Get fun facts, tips, and more from Windows and Cortana on your lock screen

*These changes may not be fully functional

## Removing Bloatware Apps - RemoveBloatwareApps.ps1
Remove the following* pre/auto-installed applications if they are installed (on a fresh OS imagee):
- Intel Graphics Control Panel
- Intel Graphics Experience
- Intel Optane Memory and Storage Management
- Power2Go for Lenovo
- PowerDVD for Lenovo
- Lenovo Companion
- Microsoft:
  - 3D Builder
  - Cortana
  - News
  - Sports
  - Weather
  - Copilot
  - Gaming App (Old version of Xbox App)
  - Get Started
  - Office Hub
  - Microsoft Solitare Collection
  - Mixed Reality
  - OneNote (Store App)
  - Power Automate Desktop
  - Skype
  - Maps
  - Phone
  - Xbox (and its components)
  - Music
  - Movies & TV
  - Microsoft Family
- Realtek Audio Control

*This is an evolving list so check the actual script to see the all of the apps