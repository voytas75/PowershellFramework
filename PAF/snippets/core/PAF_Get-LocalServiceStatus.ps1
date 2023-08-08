<#
.SYNOPSIS
Get the status of a specified service on the local computer.

.DESCRIPTION
This function retrieves the current status (running, stopped, etc.) of a specified service on the local computer.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-LocalServiceStatus {
    <#
    :CATEGORY
    Example
    :NAME
    Get-LocalServiceStatus
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false)]
        [string]$ServiceName
    )
    
    process {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "Service '$ServiceName' status: $($service.Status)"
        }
        else {
            Write-Host "Service '$ServiceName' not found on the local computer."
        }
    }
}
    
# The snippet must have code to run the function(s) when invoked by PAF.
$serviceName = Read-Host -Prompt "Enter the service name"
Get-LocalServiceStatus -ServiceName $serviceName
    