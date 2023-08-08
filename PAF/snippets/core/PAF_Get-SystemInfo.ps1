<#
.Synopsis
This snippet retrieves basic system information such as OS version, computer name, and total RAM.

.Description
This script demonstrates how to retrieve basic system information using WMI and CIM cmdlets.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-SystemInfo {
    <#
:CATEGORY
Example
:NAME
Get-SystemInfo
#>

    # Check if PowerShell version is 7 or higher
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -ge 7) {
        $osVersion = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Caption
        $computerName = $env:COMPUTERNAME
        $totalRAM = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory) / 1GB
    }
    else { # Check if PowerShell version is < 7
        $osVersion = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
        $computerName = $env:COMPUTERNAME
        $totalRAM = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory) / 1GB
    }
    $systemInfo = @{
        OSVersion    = $osVersion
        ComputerName = $computerName
        TotalRAM_GB  = $totalRAM
    }

    return $systemInfo
}
Get-SystemInfo