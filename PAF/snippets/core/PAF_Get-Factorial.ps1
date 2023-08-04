<#
.SYNOPSIS
Calculate the factorial of a given number.

.DESCRIPTION
This function calculates the factorial of a positive integer.
#>


function Get-Factorial {
    <#
    :CATEGORY
    Math

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
            $result
        }
        else {
            throw "Factorial is only defined for positive integers greater than 1."
        }
    }
}
    
# The snippet must have code to run the function(s) when invoked by PAF.
Get-Factorial -Number 5
    