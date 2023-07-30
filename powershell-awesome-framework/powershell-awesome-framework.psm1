# Function to read JSON configuration file
function Get-PAFConfiguration {
    param (
        [Parameter(Position = 0)]
        [string]$configFilePath = (Join-Path $PSScriptRoot 'config.json')
    )

    Write-Verbose ((Join-Path $PSScriptRoot 'config.json') | Out-String)

    if (-not (Test-Path $configFilePath)) {
        Write-Warning "Configuration file not found. Using default values."
        return Get-PAFDefaultConfiguration
    }

    try {
        $configData = Get-Content -Path $configFilePath | ConvertFrom-Json
        return $configData
    }
    catch {
        Write-Error "Error reading configuration file: $_"
        return $null
    }
}

function Get-PAFDefaultConfiguration {
    return @{
        "FrameworkName"       = "PowerShell Awesome Framework"
        "DefaultModulePath"   = $PSScriptRoot
        "SnippetsPath"        = "${PSScriptRoot}\snippets\core"
        "UserSnippetsPath"    = "${PSScriptRoot}\snippets\user"
        "UseColorOutput"      = $true
        "MaxSnippetsPerPage"  = 10
        "ShowBannerOnStartup" = $true
        "FrameworkPrefix"     = "PAF_"
    } # Add more keys and default values as needed
}
# Function to save updated configuration to JSON file
function Save-PAFConfiguration {
    param (
        [string]$configFilePath,
        [object]$configData
    )

    $configData | ConvertTo-Json | Set-Content -Path $configFilePath
}

# Function to load snippets from the main path
function Get-PAFSnippets {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$snippetsPath,
        [string]$frameworkPrefix
    )

    process {
        # Get the snippets path from the configuration
        Write-Verbose ($snippetsPath | Out-String)

        # Ensure the snippets path is valid
        if (-not (Test-Path -Path $snippetsPath -PathType Container)) {
            Write-Error "Snippets path '$snippetsPath' not found or invalid."
            return
        }

        # Get all snippet files in the snippets directory
        $snippetFiles = Get-ChildItem -Path $snippetsPath -Filter "${frameworkPrefix}*.ps1" -File

        # Initialize an array to store snippet metadata
        $snippetsMetadata = @()
        Write-Verbose ($snippetsMetadata | Out-String)
        # Loop through each snippet file and extract metadata
        foreach ($file in $snippetFiles) {
            Try {
                #. $file.FullName
            }
            Catch {
                Write-Error -Message "Failed to import file $($file.FullName): $_"
            }
            

            $functionName = $file.FullName -replace ($frameworkPrefix, "")
            $functionName = $functionName -replace (".ps1", "")
            #$functionName
            Write-Verbose ($file | Out-String) -Verbose

            #$functionScriptBlock = (Get-Command (split-path $functionName -Leaf)).ScriptBlock
            $functionScriptBlock = Get-Content -Path $file.FullName -Raw
            $category = Get-PAFScriptBlockCategory -ScriptBlock $functionScriptBlock
            if ($null -eq $category) {
                $category = "No category"            }

            $functionName = Get-PAFScriptBlockName -ScriptBlock $functionScriptBlock
            if ($null -eq $functionName) {
                $functionName = $file.FullName            }
            $metadata = Get-Help -Name $file.FullName -full | `
                Select-Object -Property Synopsis, `
            @{l = "Description"; e = { $_.Description.Text } }, `
            @{l = "Category"; e = { $category } }

            $snippetMetadata = [PSCustomObject]@{
                'name'        = $functionName
                'synopsis'    = $metadata.Synopsis
                'description' = $metadata.Description.ToString()
                'category'    = $metadata.Category.ToString()
                'path'        = $file.FullName
            }

            $snippetsMetadata += $snippetMetadata
        }

        return $snippetsMetadata
    }
}

# Main menu function with snippet categories
function Show-PAFSnippetMenu {
    param (
        [string]$searchKeywords = $null,
        [string]$category = $null,
        [string]$usersnippetsPath = $null,
        [string]$systemsnippetsPath = $null,
        [string]$frameworkPrefix
    )

    try {
        # Caching snippets to avoid repeated file I/O
        if (-not $script:cachedSnippets) {
            $script:cachedSnippets = @()
            $script:cachedSnippets += Get-PAFSnippets -snippetsPath $usersnippetsPath -frameworkPrefix $frameworkPrefix
            $script:cachedSnippets += Get-PAFSnippets -snippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix
        }

        $allSnippets = $script:cachedSnippets

        # Filter snippets based on search keywords
        if ($searchKeywords) {
            $allSnippets = $allSnippets | Where-Object {
                $_.Name -like "*$searchKeywords*" -or $_.synopsis -like "*$searchKeywords*" -or $_.description -like "*$searchKeywords*"
            }
        }

        # Display categories if no category specified, or display snippets for the chosen category
        if (-not $category) {
            $categories = $allSnippets | Select-Object -ExpandProperty Category -Unique
            Write-Host "Available Categories:"
            $categoriesWithNumbers = $categories | ForEach-Object -Begin { $count = 1 } -Process {
                Write-Host "$count. $_"
                $count++
            }

            # Prompt user for category selection
            $selection = Read-Host "Enter the number of the category you want to browse (press Enter to continue without search)"

            if ($selection -ge 1 -and $selection -le $categories.Count) {
                $category = $categories[$selection - 1]
            }
        }

        # Filter snippets based on the chosen category
        if ($category) {
            $categorySnippets = @()
            $categorySnippets += $allSnippets | Where-Object {
                $_.Category -eq $category
            }

            Write-Output "Snippets in '$category' category:"
            $SnippetsWithNumbers = $categorySnippets | ForEach-Object -Begin { $count = 1 } -Process {
                Write-Host "$count. $($_.name)"
                $count++
            }

<#             $categorySnippets | ForEach-Object {
                Write-Host "$($_.Name). '$($_.Name)' $($_.Synopsis)"
            }
 #>
            # Prompt user to choose a snippet to execute
            $executeSnippet = Read-Host "Enter the number of the snippet you want to execute (press Enter to continue without execution)"
            $categorySnippets.Count
            if ($executeSnippet -ge 1 -and $executeSnippet -le $categorySnippets.Count) {
                $selectedSnippet = $categorySnippets[$executeSnippet - 1]
                Write-Host "Executing snippet function: $($selectedSnippet.Name) ($($selectedSnippet.Path))..."
                Invoke-Expression "& { . $($selectedSnippet.Path) }"
            }
            else {
                Write-Host "Continuing without snippet execution."
            }
        }
        else {
            Write-Host "Continuing without category selection."
        }
    }
    catch {
        Write-Error "Error in Show-PAFSnippetMenu: $_"
    }
}

# Gets name of category from snippet; must be definied by user in script
function Get-PAFScriptBlockCategory {
<#
.SYNOPSIS
    Get the category from a PowerShell script block.

.DESCRIPTION
    This function extracts the category information from a PowerShell script block that contains the ":CATEGORY" tag.

.PARAMETER ScriptBlock
    The PowerShell script block from which to extract the category.

.EXAMPLE
    Get-PAFScriptBlockCategory -ScriptBlock {
        # Some script code here
        :CATEGORY
        MyCategory
        # More script code
    }
    # Output: "MyCategory"

.EXAMPLE
    > $functionScriptBlock = (Get-Command Get-Example).ScriptBlock
    > $category = Get-PAFScriptBlockCategory -ScriptBlock $functionScriptBlock
    > Write-Host "Category: $category"
    # Output: "Category: Example"
#>


[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $ScriptBlock
    )

    try {
        # Convert the script block to a string
        $scriptText = $ScriptBlock.ToString()

        # Define the regex pattern to match the :CATEGORY tag
        $categoryRegex = '.*\:CATEGORY\s+(.+)'

        # Attempt to find the :CATEGORY tag in the script text
        $match = $scriptText | Select-String -Pattern $categoryRegex -AllMatches

        if ($match.Matches.Count -gt 0) {
            $category = $match.Matches[0].Groups[1].Value
            $category = $category.TrimEnd([Environment]::NewLine)
            return $category
        }
    }
    catch {
        Write-Warning "An error occurred while extracting the category: $_"
    }

    return $null
}

# Gets name of main function in snippet; must be definied by user in script   
function Get-PAFScriptBlockName {
<#
.SYNOPSIS
    Get the main function name from a PowerShell script block.

.DESCRIPTION
    This function extracts the main function name information from a PowerShell script block that contains the ":NAME" tag.

.PARAMETER ScriptBlock
    The PowerShell script block from which to extract the main function name.

.EXAMPLE
    Get-PAFScriptBlockName -ScriptBlock {
        # Some script code here
        :Name 
        MyName
        # More script code
    }
    # Output: "MyName"

.EXAMPLE
    > $functionScriptBlock = (Get-Command Get-Example).ScriptBlock
    > $name = Get-PAFScriptBlockName -ScriptBlock $functionScriptBlock
    > Write-Host "Name: $name"
    # Output: "Name: Get-Example"
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $ScriptBlock
    )

    try {
        # Convert the script block to a string
        $scriptText = $ScriptBlock.ToString()

        # Define the regex pattern to match the :NAME tag
        $nameRegex = '.*\:NAME\s+(.+)'

        # Attempt to find the :NAME tag in the script text
        $match = $scriptText | Select-String -Pattern $nameRegex -AllMatches

        if ($match.Matches.Count -gt 0) {
            $name = $match.Matches[0].Groups[1].Value
            $name = $name.TrimEnd([Environment]::NewLine)
            return $name
        }
    }
    catch {
        Write-Warning "An error occurred while extracting the name: $_"
    }

    return $null
}


function Start-PAF {
    try {
        $configData = Get-PAFConfiguration
        $usersnippetsPath = $configData.UserSnippetsPath
        $systemsnippetsPath = $configData.SnippetsPath
        $frameworkPrefix = $configData.FrameworkPrefix

        # Caching snippets to avoid repeated file I/O
        $script:cachedSnippets = @()
        $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $usersnippetsPath -frameworkPrefix $frameworkPrefix)
        $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix)

        Show-PAFSnippetMenu -usersnippetsPath $usersnippetsPath -systemsnippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix
        Show-PAFSnippetMenu -usersnippetsPath $usersnippetsPath -systemsnippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix -category "" -searchKeywords ""
    }
    catch {
        Write-Error "Error in Start-PAF: $_"
    }
}


# Export the functions to make them available to users of the module
#Export-ModuleMember -Function Read-Configuration, Save-Configuration, Get-Snippets, Get-UserSnippets, Show-SnippetMenu

# Example usage of reading and modifying settings
#$configFilePath = "C:\Path\To\Config\config.json"
#$configuration = Read-Configuration -configFilePath $configFilePath

# Access specific settings
#$defaultModulePath = $configuration.DefaultModulePath
#$useColorOutput = $configuration.UseColorOutput

# Modify settings
#$configuration.UseColorOutput = $false
#Save-Configuration -configFilePath $configFilePath -configData $configuration


########### TESTS #########
# read configuration
#write-output "PSScriptRoot: $PSScriptRoot"
#Get-ChildItem $PSScriptRoot

#$configData = Read-Configuration
#$configData

#write-output $PSScriptRoot


# Get the snippets using the Get-Snippets function with pipeline input
#$snippets = $configData | Get-Snippets
#$snippets

# Get user-defined snippets from the user snippets folder
#$userSnippets = Get-UserSnippets -UserSnippetsPath $configData.userSnippetsPath
#$userSnippets

# Function to dynamically load snippets from modules (you can integrate this function as shown in the previous response)
# Main script to load the framework and display the menu
#Get-Snippets
#Get-UserSnippets
#Show-SnippetMenu




# Create fingerprint
..\helpers\moduleFingerprint.ps1