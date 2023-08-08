<#
.SYNOPSIS
Get information about the memory (RAM) on the local computer.

.DESCRIPTION
This function retrieves detailed information about the memory (RAM) on the local computer, such as total physical memory and available memory.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-LocalMemoryInfo {
    <#
    :CATEGORY
    Example
    :NAME
    Get-LocalMemoryInfo
    #>
        [CmdletBinding()]
        param ()
    
        process {
            $memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory
            if ($memoryInfo) {
                $totalMemoryGB = [math]::Round(($memoryInfo | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
                $availableMemoryGB = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2) #the original number is just given in KB
    
                Write-Host "Total Physical Memory: $totalMemoryGB GB"
                Write-Host "Available Memory: $availableMemoryGB GB"
            } else {
                Write-Host "Unable to retrieve memory information on the local computer."
            }
        }
    }
    
    # The snippet must have code to run the function(s) when invoked by PAF.
    Get-LocalMemoryInfo
    