# Path of desktop to load shortcuts to. Default to public desktop. INCLUDE TRAILING SLASH
$PublicPath = "C:\Users\Public\Desktop\"

# An array of server addresses to create shortcuts for
$Addresses = @("server1.com", "server2.com")

# A CORRESPONDING array of names for the shortcuts
$Names = @("Server 1", "Server 2")

# A boolean to decide whether to use Entra authentication to the remote computer
$EntraAuth = $true

# Test if the public path exists, create it if it does not
if (!(Test-Path -Path $PublicPath)) {
    New-Item -ItemType Directory -Path $PublicPath
}

function Set-RDPShortcut {
    param(
        # Parameter help description
        [Parameter(Mandatory, Position = 0)]
        [String] $ShortcutName,
        [Parameter(Mandatory, Position = 1)]
        [String] $Address,
        [Parameter(Mandatory, Position = 2)]
        [Bolean] $RemoteAuth
    )
    # Create a copy of the RDP Template as a string
    $RDPFile = New-Object System.Collections.Generic.List[String]
    $RDPFile.Add("$RDPTemplate")

    # Add address to the RDP Template
    $RDPFile.Add("full address:s:$Address")

    # Enable Entra/Remote auth if chosen, otherwise keep it disabled
    if ($EntraAuth -eq $true){
        $RDPFile.Add("enablerdsaadauth:i:1")
    }
    else {
        $RDPFile.Add("enablerdsaadauth:i:0")
    }

    #Output the file to the specified path
    $RDPFile | Out-File -FilePath "$PublicPath$ShortcutName.rdp"
    
}



$RDPTemplate = @"
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1920
desktopheight:i:1080
session bpp:i:32
winposstr:s:0,3,0,0,800,600
compression:i:1
keyboardhook:i:2
audiocapturemode:i:1
videoplaybackmode:i:1
connection type:i:7
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
remoteappmousemoveinject:i:1
disable wallpaper:i:0
allow font smoothing:i:0
allow desktop composition:i:0
disable full window drag:i:1
disable menu anims:i:1
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
audiomode:i:0
redirectprinters:i:1
redirectlocation:i:0
redirectcomports:i:0
redirectsmartcards:i:1
redirectwebauthn:i:1
redirectclipboard:i:1
redirectposdevices:i:0
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:0
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:0
gatewaybrokeringtype:i:0
use redirection server name:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:
drivestoredirect:s:
camerastoredirect:s:*
devicestoredirect:s:*
"@

# Turn the arrays into an object
$RDPConnections = @()
for ($i = 0; $i -lt $Addresses.Count; $i++) {
    $Server = [PSCustomObject]@{
        Address = $Addresses[$i]
        Name = $Names[$i]
    }
    $RDPConnections += $Server
}

$RDPConnections | ForEach-Object {
    Set-RDPShortcut -ShortcutName $_.Name -Address $_.Address -RemoteAuth $EntraAuth
    Write-Host "Created RDP Shortcut: $_.Name with Address: $_.Address"
}