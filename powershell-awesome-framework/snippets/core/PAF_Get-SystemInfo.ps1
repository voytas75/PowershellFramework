<#
.Synopsis
This snippet retrieves basic system information such as OS version, computer name, and total RAM.

.Description
This script demonstrates how to retrieve basic system information using WMI and CIM cmdlets.
#>

function Get-SystemInfo {
<#
:CATEGORY
utility
#>
$osVersion = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
    $computerName = $env:COMPUTERNAME
    $totalRAM = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory) / 1GB

    $systemInfo = @{
        OSVersion = $osVersion
        ComputerName = $computerName
        TotalRAM_GB = $totalRAM
    }

    return $systemInfo
}
