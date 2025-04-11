$apps = @(
    "57540AMZNMobileLLC.AmazonAlexa"
    "AppUp.IntelGraphicsControlPanel"
    "AppUp.IntelGraphicsExperience"
    "AppUp.IntelOptaneMemoryandStorageManagement"
    "CyberLinkCorp.th.Power2GoforLenovo"
    "CyberLinkCorp.th.PowerDVDforLenovo"
    "DellInc.DellCustomerConnect"
    "DellInc.DellDigitalDelivery"
    "DellInc.DellSupportAssistforPCs"
    "DellInc.DellUpdate"
    "DellInc.MyDell"
    "E046963F.LenovoCompanion"
    "Microsoft.3DBuilder"
    "Microsoft.549981C3F5F10"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    "Microsoft.Copilot"
    "Microsoft.GamingApp"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality"
    "Microsoft.Office.OneNote"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftCorporationII.MicrosoftFamily"
    "PortraitDisplays.DellCinemaColor"
    "RealtekSemiconductorCorp.RealtekAudioControl"
    "STMicroelectronicsMEMS.DellFreeFallDataProtection"
    "WavesAudio.MaxxAudioProforDell2022"
)

foreach ($app in $apps) {
    try {
        if (Get-AppxPackage -Name "$app" -AllUsers) {
            Write-Host "-- Removing $app"
            Get-AppxPackage -Name "$app" -AllUsers | Remove-AppxPackage -AllUsers
        }
        else {
            Write-Host "! Application `"$app`" not found"
        }
    }
    catch {
        Write-Host "Error uninstalling application `"$app`""
        Write-Host $Error
    }
}