<#
.SYNOPSIS
Get recently modified files in a folder and its subfolders.

.DESCRIPTION
This function lists the most recently modified files present in the specified folder and its subfolders.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-RecentFiles {
    <#
    :CATEGORY
    Example
    :NAME
    Get-RecentFiles
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $false)]
        [string]$FolderPath
    )
    
    process {
        if (-not $FolderPath) {
            $FolderPath = Read-Host "Enter the folder path"
        }
    
        if (Test-Path $FolderPath -PathType Container) {
            Get-ChildItem -Path $FolderPath -Recurse -File | Sort-Object -Property LastWriteTime -Descending
        }
        else {
            throw "The specified folder path does not exist."
        }
    }
}
    
# The snippet must have code to run the function(s) when invoked by PAF.
Get-RecentFiles
    