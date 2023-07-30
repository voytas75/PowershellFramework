# Function to read JSON configuration file
function Get-PAFConfiguration {
    <#
    .SYNOPSIS
    Reads the JSON configuration file and returns the configuration data.

    .DESCRIPTION
    This function reads the JSON configuration file specified by the ConfigFilePath parameter and converts it to a PowerShell object.
    It validates the structure of the configuration file and returns the configuration data.

    .PARAMETER ConfigFilePath
    The path to the JSON configuration file. If not specified, the default path is used.

    .EXAMPLE
    Get-PAFConfiguration -ConfigFilePath "C:\Path\to\config.json"
    Reads the configuration from the specified file.

    .EXAMPLE
    Get-PAFConfiguration
    Reads the configuration from the default file path.

    #>
    param (
        [Parameter(Position = 0)]
        [string]$ConfigFilePath = (Join-Path $PSScriptRoot 'config.json')
    )

    # Check if the configuration file exists
    if (-not (Test-Path $ConfigFilePath)) {
        Write-Warning "Configuration file not found at '$ConfigFilePath'. Using default values."
        return Get-PAFDefaultConfiguration
    }

    try {
        # Read the content of the configuration file and convert it to a JSON object
        $ConfigData = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json

        # Validate the configuration file structure
        $RequiredProperties = @(
            "FrameworkName",
            "DefaultModulePath",
            "SnippetsPath",
            "UserSnippetsPath",
            "MaxSnippetsPerPage",
            "ShowBannerOnStartup",
            "FrameworkPrefix"
        )

        $MissingProperties = $RequiredProperties | Where-Object { $ConfigData.PSObject.Properties.Name -notcontains $_ }

        if ($MissingProperties) {
            Write-Warning "Invalid configuration file structure. Missing properties: $MissingProperties. Using default values."
            return Get-PAFDefaultConfiguration
        }

        return $ConfigData
    }
    catch {
        Write-Error "Error reading or parsing the configuration file: $_"
        return $null
    }
}

function Get-PAFDefaultConfiguration {
    return @{
        "FrameworkName"       = "PowerShell Awesome Framework"
        "DefaultModulePath"   = $PSScriptRoot
        "SnippetsPath"        = Join-Path $PSScriptRoot 'snippets\core'
        "UserSnippetsPath"    = Join-Path $PSScriptRoot 'snippets\user'
        "MaxSnippetsPerPage"  = 10
        "ShowBannerOnStartup" = $true
        "FrameworkPrefix"     = "PAF_"
        # Add more configuration options here with their default values
        # For example:
        # "Theme"               = "Dark"
        # "LogFilePath"         = Join-Path $PSScriptRoot 'logs'
        # "EnableDebugMode"     = $false
    }
}

# Function to save updated configuration to JSON file
function Save-PAFConfiguration {
    param (
        [string]$configFilePath,
        [object]$configData
    )

    try {
        # Convert the configuration data to JSON format
        $jsonConfig = $configData | ConvertTo-Json -Depth 10

        # Save the JSON data to the configuration file
        $jsonConfig | Set-Content -Path $configFilePath -Encoding UTF8

        Write-Host "Configuration saved to '$configFilePath'."
    }
    catch {
        Write-Error "Error saving configuration to '$configFilePath': $_"
    }
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

    try {
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

        # Loop through each snippet file and extract metadata
        foreach ($file in $snippetFiles) {
            Try {
                $functionScriptBlock = Get-Content -Path $file.FullName -Raw
                # Extract information from the script block using a custom function
                $functionName = Get-PAFScriptBlockInfo -ScriptBlock $functionScriptBlock -InfoType FunctionName
                $category = Get-PAFScriptBlockInfo -ScriptBlock $functionScriptBlock -InfoType Category
                if ($null -eq $category) {
                    $category = "No category"
                }

                $metadata = Get-Help -Name $file.FullName -Full | `
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
            Catch {
                Write-Error -Message "Failed to import file $($file.FullName): $_"
            }
        }

        return $snippetsMetadata
    }
    catch {
        Write-Error "An error occurred while retrieving snippets: $_"
        return $null
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
                $_.Name -like "*$searchKeywords*" -or $_.Synopsis -like "*$searchKeywords*" -or $_.Description -like "*$searchKeywords*"
            }
        }

        # Display categories if no category specified, or display snippets for the chosen category
        if (-not $category) {
            $categories = $allSnippets | Select-Object -ExpandProperty Category -Unique
            if ($categories.Count -eq 0) {
                Write-Host "No categories found. Continuing without category selection."
            }
            else {
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
        }

        if ($category) {
            # Filter snippets based on the chosen category
            $categorySnippets = @()
            $categorySnippets += $allSnippets | Where-Object {
                $_.Category -eq $category
            }

            if ($categorySnippets.Count -eq 0) {
                Write-Host "No snippets found in the '$category' category."
            }
            else {
                Write-Output "Snippets in '$category' category:"
                $SnippetsWithNumbers = $categorySnippets | ForEach-Object -Begin { $count = 1 } -Process {
                    Write-Host "$count. $($_.Name)"
                    $count++
                }

                # Prompt user to choose a snippet to execute
                $executeSnippet = Read-Host "Enter the number of the snippet you want to execute (press Enter to continue without execution)"

                if ($executeSnippet -ge 1 -and $executeSnippet -le $categorySnippets.Count) {
                    $selectedSnippet = $categorySnippets[$executeSnippet - 1]
                    Write-Host "Executing snippet function: $($selectedSnippet.Name) ($($selectedSnippet.Path))..."
                    Invoke-Expression "& { . $($selectedSnippet.Path) }"
                }
                else {
                    Write-Host "Invalid snippet number or no snippet execution requested."
                }
            }
        }
    }
    catch {
        Write-Error "Error in Show-PAFSnippetMenu: $_"
    }
}


# Gets name of category and function from snippet; must be definied by user in script
function Get-PAFScriptBlockInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ScriptBlock,

        [Parameter(Mandatory = $true)]
        [ValidateSet("FunctionName", "Category")]
        [string]$InfoType
    )

    try {
        # Convert the script block to a string
        $scriptText = $ScriptBlock.ToString()

        # Define simplified regex patterns to match the :NAME and :CATEGORY tags
        $nameRegex = '.*:NAME\s+(.+)'
        $categoryRegex = '.*:CATEGORY\s+(.+)'

        # Initialize variables to hold extracted values
        $functionName = $null
        $category = $null

        # Attempt to find the :NAME and :CATEGORY tags in the script text
        $nameMatch = $scriptText | Select-String -Pattern $nameRegex -AllMatches
        $categoryMatch = $scriptText | Select-String -Pattern $categoryRegex -AllMatches

        # Extract the main function name value
        if ($nameMatch.Matches.Count -gt 0) {
            $functionName = $nameMatch.Matches[0].Groups[1].Value
        }

        # Extract the category value
        if ($categoryMatch.Matches.Count -gt 0) {
            $category = $categoryMatch.Matches[0].Groups[1].Value
        }

        # Determine the requested information based on $InfoType
        switch ($InfoType) {
            "FunctionName" {
                return $functionName
            }
            "Category" {
                return $category
            }
            default {
                Write-Warning "Invalid value for InfoType. Use 'FunctionName' or 'Category'."
                return $null
            }
        }
    }
    catch {
        Write-Warning "An error occurred while extracting the script block information: $_"
    }

    return $null
}

function Start-PAF {
    try {
        $configData = Get-PAFConfiguration
        if ($null -eq $configData) {
            Write-Error "Failed to load configuration. Exiting PAF."
            return
        }

        $usersnippetsPath = $configData.UserSnippetsPath
        $systemsnippetsPath = $configData.SnippetsPath
        $frameworkPrefix = $configData.FrameworkPrefix

        if ($configData.ShowBannerOnStartup -and $null -eq $bannerShowed ) {
            get-banner
            $bannerShowed = $true
        }

        while ($true) {
            
            # Caching snippets to avoid repeated file I/O
            $script:cachedSnippets = @()
            $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $usersnippetsPath -frameworkPrefix $frameworkPrefix)

            $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix)

            Show-PAFSnippetMenu -usersnippetsPath $usersnippetsPath -systemsnippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix
        }
    }
    catch {
        Write-Error "Error in Start-PAF: $_"
    }
}


function Get-Banner {
    param (
        
    )
    
    $banner = get-content -Path "./images/banner.txt"
    Write-Output $banner
    return

}


# Create fingerprint
#..\helpers\moduleFingerprint.ps1