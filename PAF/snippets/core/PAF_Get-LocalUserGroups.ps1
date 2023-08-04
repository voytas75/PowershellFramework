<#
.SYNOPSIS
Get a list of groups a specified local user is a member of.

.DESCRIPTION
This function retrieves a list of groups a specified local user is a member of on the local computer.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework.
#>


function Get-LocalUserGroups {
    <#
    :CATEGORY
    User Management
    :NAME
    Get-LocalUserGroups
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false)]
        [string]$Username
    )
    
    process {
        $user = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True' AND Name='$Username'" -ErrorAction SilentlyContinue
        if ($user) {
            $userSid = $user.SID
            $userGroups = Get-WmiObject -Class Win32_GroupUser | Where-Object { $_.PartComponent -match $userSid } | ForEach-Object {
                $groupName = ($_.GroupComponent -split "=")[-1] -replace '\\', ''
            Get-LocalGroup -Name $groupName
        }
        $userGroups
    }
    else {
        Write-Host "User '$Username' not found on the local computer."
    }
}
}
    
# The snippet must have code to run the function(s) when invoked by PAF.
$username = Read-Host "Enter the username of the local user"
Get-LocalUserGroups -Username $username
    