<#
.SYNOPSIS

Get processes info.

.DESCRIPTION

This script retrieves basic process information. Default process is 'system'

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-ProcessInfo {
<#
:CATEGORY
Example
:NAME
Get-ProcessInfo
#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$ProcessName = "system"
    )

    try {
        if (-not $PSBoundParameters.ContainsKey('ProcessName') -or $PSBoundParameters.ContainsKey('ProcessName') -eq "system") {
            Write-Host "Info: default 'ProcessName' value: $ProcessName"
        } 
        #else {
        #    Write-Host "'ProcessName' explicitly provided: $ProcessName"
        #}
    

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

# main

$process = (Read-Host -Prompt "Provide process name")
if ($process) {
    (Get-ProcessInfo -ProcessName $process)
} else {
    Get-ProcessInfo 
}
