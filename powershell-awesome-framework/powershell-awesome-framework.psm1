# Import required modules, if any
# E.g., Import-Module SomeModule

# Function to read JSON configuration file
function Read-PAFConfiguration {
    param (
        [Parameter(Position = 0)]
        [string]$configFilePath = (Join-Path $PSScriptRoot 'config.json')
    )

    Write-Verbose ((Join-Path $PSScriptRoot 'config.json') | Out-String) -Verbose

    if (-not (Test-Path $configFilePath)) {
        Write-Warning "Configuration file not found. Using default values."
        return @{
            "FrameworkName"       = "PowerShell Awesome Framework"
            "DefaultModulePath"   = "${PSScriptRoot}\\Snippets\\core"
            "SnippetsPath"        = "${PSScriptRoot}\\snippets\\user"
            "UserSnippetsPath"    = "${PSScriptRoot}\\Snippets\\user"
            "UseColorOutput"      = true
            "MaxSnippetsPerPage"  = 10
            "ShowBannerOnStartup" = true
            "FrameworkPrefix"     = "PAF_"
        } # Add more keys and default values as needed
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
        [PSObject]$ConfigData
    )
    <#     begin {
        
    }
 #>    process {
        # Get the snippets path from the configuration
        $snippetsPath = $ConfigData.SnippetsPath

        Write-Verbose ($ConfigData | Out-String) -Verbose
        Write-Verbose ($snippetsPath | Out-String) -Verbose

        # Ensure the snippets path is valid
        if (-not (Test-Path -Path $snippetsPath -PathType Container)) {
            Write-Error "Snippets path '$snippetsPath' not found or invalid."
            return
        }

        # Get all snippet files in the snippets directory
        $snippetFiles = Get-ChildItem -Path $snippetsPath -Filter "*.ps1" -File

        # Initialize an array to store snippet metadata
        $snippetsMetadata = @()

        # Loop through each snippet file and extract metadata
        foreach ($file in $snippetFiles) {
            $metadata = Get-Help -Path $file.FullName -Category Function | Select-Object -Property Name, Synopsis, Description, Category
            $snippetsMetadata += $metadata
        }

        return $snippetsMetadata
    }
}

# Function to load user-specific snippets from the additional path
function Get-PAFUserSnippets {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$UserSnippetsPath = (Join-Path $PSScriptRoot '/snippets/user/')
    )

    process {
        # Ensure the user snippets path is valid
        if (-not (Test-Path -Path $UserSnippetsPath -PathType Container)) {
            Write-Error "User snippets path '$UserSnippetsPath' not found or invalid."
            return
        }

        # Get all user snippet files in the user snippets directory
        $userSnippetFiles = Get-ChildItem -Path $UserSnippetsPath -Filter "*.ps1" -File

        # Initialize an array to store user snippet metadata
        $userSnippetsMetadata = @()

        # Loop through each user snippet file and extract metadata
        foreach ($file in $userSnippetFiles) {
            $metadata = Get-Help -Path $file.FullName -Category Function | Select-Object -Property Name, Synopsis, Description, Category
            $userSnippetsMetadata += $metadata
        }

        return $userSnippetsMetadata
    }
}

# Main menu function with snippet categories
function Show-PAFSnippetMenu {
    param (
        [string]$searchKeywords = $null,
        [string]$category = $null
    )

    # Define the naming convention for your snippets
    $frameworkPrefix = "FrameworkName_"

    # Retrieve available commands (functions) from loaded modules
    $availableCommands = Get-Command | Where-Object { $_.CommandType -eq "Function" }

    # Filter commands to include only snippets specific to your framework based on naming convention
    $snippets = $availableCommands | Where-Object { $_.Name -like "$frameworkPrefix*" }

    # Filter snippets based on search keywords
    if ($searchKeywords) {
        $snippets = $snippets | Where-Object {
            $_.Name -match $searchKeywords -or $_.ScriptBlock.ToString() -match $searchKeywords
        }
    }

    # Filter snippets based on the chosen category
    if ($category) {
        $snippets = $snippets | Where-Object {
            $_.ScriptBlock.ToString() -match ".CATEGORY $category"
        }
    }

    # Display categories if no category specified, or display snippets for the chosen category
    if (-not $category) {
        Write-Host "Available Categories:"
        $categories = $snippets | ForEach-Object {
            $_.ScriptBlock.ToString() -replace "^.*\.CATEGORY", ""
        } | Sort-Object -Unique
        $index = 1
        foreach ($categoryName in $categories) {
            Write-Host "$index. $categoryName"
            $index++
        }
    }
    else {
        Write-Host "Snippets in '${category}' Category:"
        $maxSnippetNameLength = ($snippets | ForEach-Object { $_.Name.Length }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

        for ($i = 0; $i -lt $snippets.Count; $i++) {
            $snippet = $snippets[$i]
            $snippetName = $snippet.Name -replace "^$frameworkPrefix", ""
            $snippetName = $snippetName.PadRight($maxSnippetNameLength)
            Write-Host "$($i + 1). $snippetName ($($snippet.ScriptBlock.ToString() -replace "^.*\.SYNOPSIS", ''))"
        }
    }

    # Prompt user for category selection, snippet selection, or new search keywords
    $selection = Read-Host "Enter the number of the category you want to browse, enter 'A' for all snippets, or enter new search keywords (press Enter to continue without search)"

    if ($selection -ge 1 -and $selection -le $categories.Count) {
        $selectedCategory = $categories[$selection - 1]
        Show-SnippetMenu -category $selectedCategory
    }
    elseif ($selection -eq 'A') {
        Show-SnippetMenu
    }
    elseif ($selection) {
        # User entered new search keywords, perform a new search
        Show-PAFSnippetMenu -searchKeywords $selection
    }
    else {
        Write-Host "Continuing without category selection or search."
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