<#
.SYNOPSIS
Calculate the factorial of a given number.

.DESCRIPTION
This function calculates the factorial of a positive integer.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-Factorial {
    <#
    :CATEGORY
    Example

    :NAME
    Get-Factorial
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Number
    )
    
    process {
        if ($Number -gt 1) {
            $result = 1
            for ($i = 1; $i -le $Number; $i++) {
                $result *= $i
            }
            Write-Host "Factorial of $number is $result"
        }
        else {
            throw "Factorial is only defined for positive integers greater than 1."
        }
    }
}
    
# The snippet must have code to run the function(s) when invoked by PAF.
$number = Read-Host -Prompt "Provide number to factorial"
Get-Factorial -Number $number
    