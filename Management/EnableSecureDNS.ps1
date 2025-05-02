######
# WARNING: For use on NON-AD CLIENTS/SERVERS ONLY. DoH can break some on-prem AD machines
# Win 11 and Win Server 2022 and up are supported.
######

# An array of IP addresses for the DNS servers
$addresses = @(
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::fe"
    "2620:fe::9"
)

# The DNS over HTTPS url
$url = "https://dns.quad9.net/dns-query"

#Set the DoH policy for the machine. 1 = Prohibit, 2 = Allow and upgrade if possible, 3 = require and fail if not DoH
$DoHPolicy = 2

try {
    foreach ($address in $addresses) {
        Write-Host "Setting server $address"
        Set-DnsClientDohServerAddress -ServerAddress $address -DohTemplate $url -AllowFallbackToUdp $False -AutoUpgrade $True
    }
}
catch {
    Write-Host "Error: Server does not exist in Windows' default list. Adding custom entries."
    foreach ($address in $addresses) {
        Write-Host "Adding server $address"
        Add-DnsClientDohServerAddress -ServerAddress $address -DohTemplate $url -AllowFallbackToUdp $False -AutoUpgrade $True
    }
}

# Set the new DNS settings on all adapters
Write-Host "Setting new DNS servers on all network adapters"
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $addresses

# Set the DoH policy !!!!!!!!!! Currently not being enforced for unknown reasons !!!!!!!!!!!!!!!
Write-Host "Setting DoH Policy"

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

Invoke-RegistryCheckAndSet -Path 'HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient' -Property 'DoHPolicy' -Type DWord -Value $DoHPolicy

Write-Host "Updating Group policy"
gpupdate /force

Write-Host "Flushing the DNS"
ipconfig /flushdns

Write-Host "Checking resolving server"
Resolve-DnsName go.dnscheck.tools -Type Txt | Select-Object Strings