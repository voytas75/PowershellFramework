<#
.SYNOPSIS

Get processes info.

.DESCRIPTION

This script retrieves basic process information. Default process is 'system'
#>


function Get-ProcessInfo {
<#
:CATEGORY
System Information

:NAME
Get-ProcessInfo
#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$ProcessName = "system"
    )

    try {
        if (-not $PSBoundParameters.ContainsKey('ProcessName')) {
            Write-Host "'ProcessName' used default value: $ProcessName"
        } else {
            Write-Host "'ProcessName' explicitly provided: $ProcessName"
        }
    

        $process = Get-Process -Name $ProcessName -ErrorAction Stop
        $processInfo = [pscustomobject][ordered]@{
            Name               = $process.ProcessName
            ID                 = $process.Id
            Path               = $process.Path
            Company            = $process.Company
            CPU                = $process.CPU
            Memory             = $process.WorkingSet64 / 1MB
            Description        = $process.Description
            StartTime          = $process.StartTime
            TotalProcessorTime = $process.TotalProcessorTime
            Responding         = $process.Responding
        }

        return $processInfo
    }
    catch {
        Write-Error "Process '$ProcessName' not found."
    }
}
$process = (Read-Host -Prompt "Provide process name")
if ($process) {
    Get-ProcessInfo -ProcessName $process
} else {
    Get-ProcessInfo 
}