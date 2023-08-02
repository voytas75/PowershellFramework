<#
.SYNOPSIS

Template

.DESCRIPTION

This is a template file demonstrating how to prepare a function snippet for the PowerShell Awesome Module.
#>


function Get-Example {
    <#
:CATEGORY
Put here the name of the category
:NAME
Get-Example
#>
    [CmdletBinding()]
    param (    )

    # Here goes the code for the function snippet
    return @"
To prepare a function snippet for PAF, you must follow these steps:
1. Add a prefix to the name of the snippet file (e.g., 'PAF_Get-Example.ps1').
2. Add inline help at the top of the file, and leave two empty lines after it:
<#
.SYNOPSIS

Template

.DESCRIPTION

This is a template file demonstrating how to prepare a function snippet for the PowerShell Awesome Module.
#>

3. Inside the function body, include 'category' and 'name' tags after the function declaration line, as follows:
<#
:CATEGORY
Put here the name of the category
:NAME
Get-Example
#>

4. Ensure the snippet contains logic to execute all the desired functionality.
"@
}

# The snippet must have code to run the function(s) when invoked by PAF.
Get-Example
