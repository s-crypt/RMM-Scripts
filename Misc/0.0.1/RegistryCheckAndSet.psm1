<#
 .SYNOPSIS
  Sets/updates a registry value/key, and creates it if does not exist.

 .DESCRIPTION
  Check if a registry key and/or property exists, create the key/property if it does not, and update it to the correct value.

 .PARAMETER Path
  The path of the registry property, like 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'

 .PARAMETER Property
  The registry property within the key, like 'HiberbootEnabled'

 .PARAMETER Type
  The registry data type: String, ExpandString, Binary, DWord, MultiString, QWord

 .PARAMETER Value
  Specific days (numbered) to highlight. Used for date ranges like (25..31).
  Date ranges are specified by the Windows PowerShell range syntax. These dates are
  enclosed in square brackets.

 .EXAMPLE
   # Set the registry value to disable Fast Boot
   Invoke-RegistryCheckAndSet -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Property 'HiberbootEnabled' -Type DWord -Value 0

 .EXAMPLE
   # Set registry value to disable Search Highlights
   Invoke-RegistryCheckAndSet -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Property 'EnableDynamicContentInWSB' -Type DWord -Value 0

 .EXAMPLE
   # Set registry value to disable Recall
   Invoke-RegistryCheckAndSet 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' -Property 'DisableAIDataAnalysis' -Type DWord -Value 1
#>
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
        # Check if the key and property+value exists and is correct
        if (((Test-Path -Path $Path) -contains $Property) -and ((Get-ItemProperty -Path $Path).$Property -match $Value)) {
            Write-Host "Entry `"$Property`" exists and is correct."
        }
        # If the key and property exists, but the entry value is a mismatch
        elseif (((Test-Path -Path $Path) -contains $Property) -and (-not (Get-ItemProperty -Path $Path).$Property -match $Value)) {
            Write-Host "Registry entry `"$Property`" exists, but is not the correct value. Setting correct value."
            Set-ItemProperty -Path ($Path).$Property = $Value
        }
        # If the property does dot exist
        else {
            Write-Host "Entry `"$Property`" missing. Adding to registry."
            # Create a hash table with the registry information
            $NewRegEntry = @{
                Path         = $Path
                Name         = $Property
                PropertyType = $Type
                Value        = $Value
            }
            # If the registry key exists, log it
            if (Test-Path -Path $Path) {
                Write-Host "Key `"$Path`" exists, adding registry entry `"$Property`"."
            }
            # Otherwise if the key is missing, create it
            else {
                Write-Host "Key `"$Path`" does not exist. Creating Key and registry entry `"$Property`""
                # Create the registry key since it is missing
                New-Item -Path $Path -Force | Out-Null
            }
            # Set the registry entry and its properties
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
Export-ModuleMember -Function Invoke-RegistryCheckAndSet