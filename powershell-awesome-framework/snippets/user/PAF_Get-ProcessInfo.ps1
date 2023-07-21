<#
.Synopsis
This snippet get processes info.

.Description
This script demonstrates how to retrieve basic system information using WMI and CIM cmdlets.

.Category
System Information
#>

function Get-ProcessInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$ProcessName = "system"
    )

    try {
        $process = Get-Process -Name $ProcessName -ErrorAction Stop
        $processInfo = @{
            Name = $process.ProcessName
            ID = $process.Id
            Path = $process.Path
            Company = $process.Company
            CPU = $process.CPU
            Memory = $process.WorkingSet64 / 1MB
            Description = $process.Description
            StartTime = $process.StartTime
            TotalProcessorTime = $process.TotalProcessorTime
            Responding = $process.Responding
        }

        return $processInfo
    }
    catch {
        Write-Error "Process '$ProcessName' not found."
    }
}
