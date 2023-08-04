<#
.SYNOPSIS
Get information about the CPU on the local computer.

.DESCRIPTION
This function retrieves detailed information about the CPU on the local computer, such as the number of cores and the processor name.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-LocalCPUInfo {
    <#
    :CATEGORY
    System Information
    :NAME
    Get-LocalCPUInfo
    #>
    [CmdletBinding()]
    param ()
    
    process {
        $cpuInfo = Get-WmiObject -Class Win32_Processor
        if ($cpuInfo) {
            Write-Host "Processor Name: $($cpuInfo.Name)"
            Write-Host "Number of Cores: $($cpuInfo.NumberOfCores)"
            Write-Host "Number of Logical Processors: $($cpuInfo.NumberOfLogicalProcessors)"
            Write-Host "CPU Caption: $($cpuInfo.Caption)"
        }
        else {
            Write-Host "Unable to retrieve CPU information on the local computer."
        }
    }
}
    
# The snippet must have code to run the function(s) when invoked by PAF.
Get-LocalCPUInfo
    