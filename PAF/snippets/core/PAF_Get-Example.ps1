<#
.SYNOPSIS

Template

.DESCRIPTION

Template file to show how prepare function snippet for PowerShell Awesome Module
#>


function Get-Example {
    <#
:CATEGORY
put here name of category
:NAME
Get-Example
#>
    [CmdletBinding()]
    param (    )

    # here code of function snippet
    return @"
To prepare function snippet for PAF you must prepare code in specific way:
1. Add prefix to name of snippet file (i.e. 'PAF_Get-Example.ps1')
2. Add inline help at top of file and with two empty line after it:
<#
.SYNOPSIS

Template

.DESCRIPTION

Template file to show how prepare function snippet for PowerShell Awesome Module
#>

3. Add 'category' and 'name' after in function body below function declaration line, as follows:
<#
:CATEGORY
put here name of categor
:NAME
Get-Example
#>

4. snippet must have logic execute all what user want to.
"@
}

# snippet must have code to run function(s) when invoked by PAF.
Get-Example

