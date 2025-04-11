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
Write-Host "`nSetting registry values to make Windows tolerable"

Write-Host "`nDisabling Search Highlights`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Property 'EnableDynamicContentInWSB' -Type DWord -Value 0

Write-Host "`nEnabling File Extensions in File Explorer`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Property 'HideFileExt' -Type DWord -Value 0

Write-Host "`nDisabling Fast Boot`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Property 'HiberbootEnabled' -Type DWord -Value 0

Write-Host "`nDisabling Web Search in Windows Search`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Property 'DisableSearchBoxSuggestions' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Search' -Property 'BingSearchEnabled' -Type DWord -Value 0

Write-Host "`nDisabling Local Account security questions`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\System' -Property 'NoLocalPasswordResetQuestions' -Type DWord -Value 1

Write-Host "`nSetting Telemetry Level to Basic`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Property 'AllowTelemetry' -Type DWord -Value 1

Write-Host "`nDisabling Widgets`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' -Property 'EnableFeeds' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests' -Property 'value' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' -Property 'AllowNewsAndInterests' -Type DWord -Value 0

Write-Host "`nDisable Windows spotlight`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Property 'ConfigureWindowsSpotlight' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Property 'DisableWindowsSpotlightFeatures' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableSpotlightCollectionOnDesktop' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableThirdPartySuggestions' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableSoftLanding' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableWindowsSpotlightWindowsWelcomeExperience' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableWindowsSpotlightOnActionCenter' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableWindowsSpotlightOnSettings' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableConsumerAccountStateContent' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableTailoredExperiencesWithDiagnosticData' -Type DWord -Value 1
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' -Property 'DisableCloudOptimizedContent' -Type DWord -Value 1

Write-Host "`nDisabling bloatware app suggestions`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Property 'DisableWindowsConsumerFeatures' -Type DWord -Value 1

Write-Host "`nDisabling`"Chat`" in taskbar`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Property 'TaskbarMn' -Type DWord -Value 0

Write-Host "`nDisabling`"Windows Copilot`"`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Property 'TurnOffWindowsCopilot' -Type DWord -Value 1

Write-Host "`nSet search bar to show Icon and Label`n$hr"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Search' -Property 'SearchboxTaskbarMode' -Type DWord -Value 3

Write-Host "`nDisable Windows/Copilot Recall`n$hr"
Invoke-RegistryCheckAndSet 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' -Property 'DisableAIDataAnalysis' -Type DWord -Value 1

Write-Host "`nDisabling `"Windows Suggestions`"`n$hr"
Write-Host " - Windows welcome experience"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-310093Enabled' -Type DWord -Value 0
Write-Host " - Show suggestions in start"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-338388Enabled' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SystemPaneSuggestionsEnabled' -Type DWord -Value 0
Write-Host " - Show recommendations for tips, shortcuts, new apps, and more in start"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Property 'Start_IrisRecommendations' -Type DWord -Value 0
Write-Host " - Get tips, tricks, and suggestions as you use Windows"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-338389Enabled' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SoftLandingEnabled' -Type DWord -Value 0
Write-Host " - Show me suggested content in the Settings app"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-338393Enabled' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-353694Enabled' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-353696Enabled' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-353698Enabled' -Type DWord -Value 0
Write-Host " - Show account notifications in the settings app"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications' -Property 'EnableAccountNotifications' -Type DWord -Value 0
Write-Host " - Suggest ways I can finish setting up my device to get the most out of Windows"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement' -Property 'ScoobeSystemSettingEnabled' -Type DWord -Value 0
Write-Host " - Automatic Installation of Suggested Apps"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SilentInstalledAppsEnabled' -Type DWord -Value 0
Write-Host " - `"Suggested`" app notifications (Ads for MS services)"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested' -Property 'Enabled' -Type DWord -Value 0
Write-Host " - Show me suggestions for using my mobile device with Windows (Phone Link suggestions)"
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Mobility' -Property 'OptedIn' -Type DWord -Value 0
Write-Host " - Get fun facts, tips and more from Windows and Cortana on your lock screen"
Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'ContentDeliveryAllowed' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'SubscribedContent-338387Enabled' -Type DWord -Value 0
Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Property 'RotatingLockScreenOverlayEnabled' -Type DWord -Value 0
