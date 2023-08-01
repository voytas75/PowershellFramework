# Import the PowerShell module for improved error handling and logging
Import-Module Microsoft.PowerShell.Utility

# Function to handle and log errors
function Write-ErrorLog {
    <#
    .SYNOPSIS
    Write an error message and optionally log the error to a file.

    .DESCRIPTION
    This function writes an error message to the console using Write-Error cmdlet and optionally logs the error message and exception details to a log file.

    .PARAMETER Message
    The error message to display and log.

    .PARAMETER Exception
    Optional. The exception object to log to the file. If not provided, only the error message is logged.

    .PARAMETER LogFilePath
    Optional. The path to the log file. If not specified, the log file will be created in the user-specific temporary directory with the default name "_error.log".

    .PARAMETER LogFilePrefix
    Optional. The prefix for the log file name.

    .PARAMETER Overwrite
    Optional. If specified, the function will overwrite the log file instead of appending to it.

    .EXAMPLE
    Write-ErrorLog "An error occurred while processing the data."

    Display the error message on the console and log it to "_error.log" in the user-specific temporary directory.

    .EXAMPLE
    try {
        # Some code that may throw an exception
    }
    catch {
        Write-ErrorLog "An error occurred during processing." $_
    }

    Catch the exception, display the error message on the console, and log both the message and exception details to "<pfa_prefix>_error.log".

    .EXAMPLE
    Write-ErrorLog "Failed to connect to the server." -LogFilePrefix "MyApp"

    Display the error message on the console and log it to "MyApp_error.log" in the user-specific temporary directory.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Position = 1)]
        [Exception]$Exception,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$LogFilePath,

        [string]$LogFilePrefix = "",

        [switch]$Overwrite
    )

    try {
        # Write the error message to the console
        Write-Error $Message

        # If LogFilePath is not specified, use the user-specific temporary directory as the default location
        if (-not $LogFilePath) {
            $logFileName = "${LogFilePrefix}_error.log"
            $LogFilePath = Join-Path $env:TEMP $logFileName
        }

        # Create the log file if it doesn't exist and Overwrite switch is not specified
        if (-not (Test-Path $LogFilePath) -or $Overwrite) {
            $null = New-Item -Path $LogFilePath -ItemType File
        }

        # Prepare the log entry
        $logEntry = "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $Message"

        if ($Exception) {
            $logEntry += "`r`nException:`r`n$($Exception.ToString())"
        }

        # Append or overwrite the log entry to the log file
        $logEntry | Out-File -Append:$Overwrite -FilePath $LogFilePath
    }
    catch {
        Write-Warning "An error occurred while writing to the log file: $_"
    }
}

# Function to read JSON configuration file
function Get-PAFConfiguration {
    <#
.SYNOPSIS
Get the configuration data for the PowerShell Awesome Framework (PAF).

.DESCRIPTION
This function retrieves the configuration data for the PowerShell Awesome Framework (PAF) from the JSON configuration file (config.json). If the configuration file does not exist, it will be created with default values. The configuration file allows users to customize settings and personalize the framework's behavior to match their unique coding needs.

.PARAMETER ConfigFilePath
Optional. The path to the JSON configuration file. If not specified, the default path is used, which is the same directory as the script where the PAF is imported.

.EXAMPLE
$configuration = Get-PAFConfiguration

Retrieves the configuration data from the default configuration file path.

.EXAMPLE
$customConfigFilePath = "C:\Path\to\custom\config.json"
$configuration = Get-PAFConfiguration -ConfigFilePath $customConfigFilePath

Retrieves the configuration data from a custom configuration file path.

.OUTPUTS
System.Management.Automation.PSCustomObject
Returns a PowerShell custom object representing the configuration data.

.NOTES
The configuration file (config.json) stores the following properties:
- FrameworkName: The name of the PowerShell Awesome Framework.
- DefaultModulePath: The default path where PAF is installed.
- SnippetsPath: The path to the core snippets directory.
- UserSnippetsPath: The path to the user-specific snippets directory.
- MaxSnippetsPerPage: The maximum number of snippets displayed per page in the snippet menu.
- ShowBannerOnStartup: A boolean value indicating whether to show the PAF banner on startup.
- FrameworkPrefix: The prefix used to identify PAF-specific snippets.

To customize the configuration, manually edit the values in the config.json file using a text editor.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework (replace with the actual repository URL).

#>
    param (
        [Parameter(Position = 0)]
        [string]$ConfigFilePath
    )

    if (-not $ConfigFilePath) {
        $ConfigFilePath = (Join-Path $PSScriptRoot 'config.json')
    }

    # Check if the configuration file exists
    if (-not (Test-Path $ConfigFilePath)) {
        # Create the configuration file with default values
        $defaultConfigData = Get-PAFDefaultConfiguration
        $defaultConfigData | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigFilePath -Encoding UTF8
        Write-Host "Configuration file created at '$ConfigFilePath'."
    }

    try {
        # Read the content of the configuration file and convert it to a JSON object
        $ConfigData = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
        # add ConfigPath to object
        $ConfigData | Add-Member -NotePropertyName "ConfigPath" -NotePropertyValue $ConfigFilePath

        # Check if all required properties are present in the configuration data
        $requiredProperties = @("FrameworkName", "DefaultModulePath", "SnippetsPath", "UserSnippetsPath", "MaxSnippetsPerPage", "ShowBannerOnStartup", "FrameworkPrefix")
        if (-not (Test-RequiredProperty -Object $ConfigData -Property $requiredProperties)) {
            Write-Warning "Invalid configuration file structure. Missing required properties. Using default values."
            return Get-PAFDefaultConfiguration
        }

        return $ConfigData
    }
    catch {
        Write-Error "Error reading or parsing the configuration file: $_"
        return $null
    }
}

# Function to test if required properties are present in an object
function Test-RequiredProperty {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Object,

        [Parameter(Mandatory = $true)]
        [string[]]$Property
    )

    process {
        foreach ($prop in $Property) {
            if (-not $Object.PSObject.Properties.Name.Contains($prop)) {
                Write-Error "Required property '$prop' not found in the object."
                return $false
            }
        }

        return $true
    }
}

<# 
# Function to retrieve the default configuration settings for the PowerShell Awesome Framework (PAF).
# These settings are used when a configuration file is not found or when required properties are missing in the file.
# The function returns a hashtable containing various default configuration options.
#>
function Get-PAFDefaultConfiguration {
    $documentsFolder = [Environment]::GetFolderPath("MyDocuments")
    $newUserSnippetsPath = Join-Path $documentsFolder 'PowerShell Awesome Framework\user_snippets'
    
    if (-not (Test-Path -Path $newUserSnippetsPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $newUserSnippetsPath | Out-Null
    }

    return @{
        "FrameworkName"       = "PowerShell Awesome Framework"
        "DefaultModulePath"   = $PSScriptRoot
        "SnippetsPath"        = Join-Path $PSScriptRoot 'snippets\core'
        "UserSnippetsPath"    = $newUserSnippetsPath
        "MaxSnippetsPerPage"  = 10
        "ShowBannerOnStartup" = $true
        "FrameworkPrefix"     = "PAF"
        # Add more configuration options here with their default values
        # For example:
        # "Theme"               = "Dark"
        # "LogFilePath"         = Join-Path $PSScriptRoot 'logs'
        # "EnableDebugMode"     = $false
    }
}

# Function to save updated configuration to JSON file
function Save-PAFConfiguration {
    <#
    .SYNOPSIS

    Save the PowerShell Awesome Framework (PAF) configuration to a JSON file.

    .DESCRIPTION

    This function allows you to save the configuration data of PAF to a JSON file.
    You can either save the entire configuration data or an individual setting.

    .PARAMETER ConfigFilePath

    The path to the JSON configuration file. If not specified, the default path is used (script root).

    .PARAMETER ConfigData

    The configuration data object to be saved. If not specified, the default PAF configuration will be used.

    .PARAMETER SettingName

    The name of the individual setting to save. If provided, the function will update and save only this setting.

    .PARAMETER Encoding

    The encoding to be used when saving the configuration data. The default is UTF8.

    .EXAMPLE

    Save-PAFConfiguration -ConfigFilePath "C:\Path\to\config.json"
    Save the entire PAF configuration to the specified file path.

    .EXAMPLE

    Save-PAFConfiguration -SettingName "FrameworkName" -ConfigFilePath "C:\Path\to\config.json"
    Save the individual setting 'FrameworkName' to the specified file path.

    .EXAMPLE

    Save-PAFConfiguration -ConfigData $customConfigData -ConfigFilePath "C:\Path\to\config.json"
    Save the custom configuration data to the specified file path.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$configFilePath,

        [Parameter(Mandatory = $false)]
        [object]$configData,

        [string]$settingName = $null, # New parameter to specify the individual setting to save

        [string]$encoding = 'UTF8'
    )
  
    try {
        # If no parameters are provided, display instructions on how to use the function
        if (-not $PSBoundParameters.GetEnumerator().MoveNext()) {
            Write-Host "To save an individual setting, use the following command:"
            Write-Host "Save-PAFConfiguration -SettingName 'SettingName'"

            Write-Host "`nTo get more help"
            Write-Host "get-help Save-PAFConfiguration"

            Write-Host "`nTo display setting and values:"
            Write-Host "Get-PAFConfiguration"
            
            return
        }

        if (-not $configFilePath) {
            $configFilePath = "${PSScriptRoot}\config.json"
        }

        if (-not $configData) {
            $configData = Get-PAFConfiguration
        }


        # Validate the provided file path
        if (-not (Test-Path -Path $configFilePath)) {
            Write-Error "The configuration file path '$configFilePath' does not exist."
            return
        }

        # Get the list of valid settings from the configuration data
        $validSettings = $configData.PSObject.Properties.Name

        if ($settingName -ne $null) {
            # Check if the provided setting is a valid setting in the configuration
            if ($validSettings -contains $settingName) {
                # Prompt the user to enter the new value for the setting
                $newValue = Read-Host "Enter the new value for setting '$settingName'"

                # Update the value of the setting in the configuration data
                $configData.$settingName = $newValue

                # Save the entire updated configuration data to the configuration file
                $jsonConfig = $configData | ConvertTo-Json -Depth 10

                # Save the JSON data to the configuration file
                $jsonConfig | Set-Content -Path $configFilePath -Encoding $encoding

                Write-Host "Setting '$settingName' updated and saved to '$configFilePath'."
            }
            else {
                Write-Error "Setting '$settingName' not found in the configuration data."
            }
        }
        else {
            # Save the entire configuration data to the configuration file
            $jsonConfig = $configData | ConvertTo-Json -Depth 10

            # Save the JSON data to the configuration file
            $jsonConfig | Set-Content -Path $configFilePath -Encoding $encoding

            Write-Host "Configuration saved to '$configFilePath'."
        }
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
                $functionName = Get-PAFScriptBlockInfo -ScriptText $functionScriptBlock -InfoType FunctionName
                $category = Get-PAFScriptBlockInfo -ScriptText $functionScriptBlock -InfoType Category
                if ($null -eq $category) {
                    $category = "No category"
                }

                $metadata = Get-Help -Name $file.FullName -Full | Select-Object -Property Synopsis, `
                @{l = "Description"; e = { $_.Description.Text } }, `
                @{l = "Category"; e = { $category } }

                $snippetMetadata = [PSCustomObject]@{
                    'Name'        = $functionName
                    'Synopsis'    = $metadata.Synopsis
                    'Description' = $metadata.Description.ToString()
                    'Category'    = $metadata.Category.ToString()
                    'Path'        = $file.FullName
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
# Improved Show-PAFSnippetMenu with better error handling and comments
function Show-PAFSnippetMenu {
    [CmdletBinding()]
    param (
        [string]$SearchKeywords = $null,
        [string]$UserSnippets = $null,
        [string]$SystemSnippets = $null,
        [string]$FrameworkPrefix
    )

    try {
        if (-not $SearchKeywords) {
            $SearchKeywords = Read-Host "Enter search keywords to find snippets (press Enter to skip search)"
        }

        # Caching snippets to avoid repeated file I/O
        if (-not $script:cachedSnippets) {
            $script:cachedSnippets = @()
            $script:cachedSnippets += Get-PAFSnippets -SnippetsPath $UserSnippets -FrameworkPrefix $FrameworkPrefix
            $script:cachedSnippets += Get-PAFSnippets -SnippetsPath $SystemSnippets -FrameworkPrefix $FrameworkPrefix
        }

        $allSnippets = $script:cachedSnippets

        if ($SearchKeywords) {
            [array]$matchedSnippets = $allSnippets | Where-Object {
                $_.Name -like "*$SearchKeywords*" -or $_.Synopsis -like "*$SearchKeywords*" -or $_.Description -like "*$SearchKeywords*"
            }

            if ($matchedSnippets.Count -eq 0) {
                Write-Host "No snippets found matching the search keywords '$SearchKeywords'."
                return
            }
            else {
                Show-SnippetExecutionMenu -Snippets $matchedSnippets
                return
            }
        }

        $categories = $allSnippets | Select-Object -ExpandProperty Category -Unique
        if ($categories.Count -eq 0) {
            Write-Host "No categories found. Continuing without category selection."
            return
        }

        # Show a menu for category selection
        $categorySelection = $categories | ForEach-Object { $_ }
        $categorySelection += "All Categories"

        do {
            Write-Host "Available Categories:"
            for ($i = 0; $i -lt $categorySelection.Count; $i++) {
                Write-Host "$($i + 1). $($categorySelection[$i])"
            }

            $categoryInput = Read-Host "Enter the number of the category you want to browse (press Enter for all categories)"

            if ([string]::IsNullOrEmpty($categoryInput)) {
                $Category = $null
                break
            }
            elseif ($categoryInput -ge 1 -and $categoryInput -le $categorySelection.Count) {
                $Category = $categorySelection[$categoryInput - 1]
                break
            }
            else {
                Write-Warning "Invalid category number. Try again."
            }
        } while ($true)

        if ($Category) {
            if ($Category -eq "All Categories") {
                Show-SnippetExecutionMenu -Snippets $allSnippets
            }
            else {
                [array]$categorySnippets = $allSnippets | Where-Object {
                    $_.Category -eq $Category
                }

                if ($categorySnippets.Count -eq 0) {
                    Write-Host "No snippets found in the '$Category' category."
                }
                else {
                    Show-SnippetExecutionMenu -Snippets $categorySnippets
                }
            }
        }
    }
    catch {
        Write-Error "An error occurred in Show-PAFSnippetMenu: $_"
    }
}

# Function to display the menu for executing selected snippets
function Show-SnippetExecutionMenu {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Snippets
    )

    $selectionMade = $false

    do {
        Write-Output "Snippets:"
        $SnippetsWithNumbers = $Snippets | ForEach-Object -Begin { $count = 1 } -Process {
            Write-Host "${count}. $($_.Name)"
            $count++
        }

        # Prompt user to choose a snippet to execute or search again
        $executeSnippet = Read-Host "Enter the number of the snippet you want to execute (press Enter to search again or 'Q' to quit without execution)"

        if ($executeSnippet -eq 'Q' -or $executeSnippet -eq 'q') {
            return
        }

        if ($executeSnippet -ge 1 -and $executeSnippet -le $Snippets.Count) {
            $selectedSnippet = $Snippets[$executeSnippet - 1]
            Write-Host "Executing snippet function: $($selectedSnippet.Name) ($($selectedSnippet.Path))..."
            Invoke-Expression "& { . '$($selectedSnippet.Path)' }"
            $selectionMade = $true
        }
        else {
            Write-Warning "Invalid snippet number or no snippet execution requested."
        }
    } while (-not $selectionMade)
}

# Gets name of category and function from snippet; must be definied by user in script
function Get-PAFScriptBlockInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ScriptText,

        [Parameter(Mandatory = $true)]
        [ValidateSet("FunctionName", "Category")]
        [string]$InfoType
    )

    try {
        # Define simplified regex patterns to match the :NAME and :CATEGORY tags at the beginning of a line
        #$nameRegex = '^\s*:NAME\s+(.+)$'
        #$categoryRegex = '^\s*:CATEGORY\s+(.+)$'
        $nameRegex = '.*:NAME\s+(.+)'
        $categoryRegex = '.*:CATEGORY\s+(.+)'

        # Initialize variables to hold extracted values
        $functionName = $null
        $category = $null

        # Attempt to find the :NAME and :CATEGORY tags in the script text
        $nameMatch = $ScriptText | Select-String -Pattern $nameRegex -AllMatches
        $categoryMatch = $ScriptText | Select-String -Pattern $categoryRegex -AllMatches

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
                return (Convert-FirstLetterToUpper -InputString $category)
            }
            default {
                Write-Warning "Invalid value for InfoType. Use 'FunctionName' or 'Category'."
                return $null
            }
        }
    }
    catch [System.Management.Automation.PSInvalidOperationException] {
        Write-Warning "Error occurred during the operation: $_"
    }
    catch [System.Text.RegularExpressions.RegexMatchTimeoutException] {
        Write-Warning "Regex matching timed out: $_"
    }
    catch {
        Write-Warning "An unexpected error occurred while extracting the script block information: $_"
    }

    return $null
}

function Convert-FirstLetterToUpper {
    param (
        [string]$InputString
    )

    if (-not [string]::IsNullOrWhiteSpace($InputString)) {
        $firstLetter = $InputString.Substring(0, 1).ToUpper()
        $restOfString = $InputString.Substring(1)
        $convertedString = $firstLetter + $restOfString
        return $convertedString
    }

    return $InputString
}

# Function to start the PowerShell Awesome Framework
function Start-PAF {
    <#
.SYNOPSIS
Start the PowerShell Awesome Framework (PAF) and display the main menu of snippets.

.DESCRIPTION
This function starts the PowerShell Awesome Framework (PAF) and displays the main menu of snippets. The PAF configuration is retrieved using the Get-PAFConfiguration function. If the configuration cannot be loaded, an error is displayed, and PAF exits. The function then proceeds to cache the snippets to avoid repeated file I/O and displays the main menu to the user.

.PARAMETER None
No parameters are required.

.EXAMPLE
Start-PAF

Starts the PowerShell Awesome Framework (PAF) and displays the main menu.

.NOTES
The Start-PAF function uses the following helper functions to perform its tasks:
- Get-PAFConfiguration: Retrieves the PAF configuration data from the JSON configuration file.
- Get-PAFSnippets: Retrieves the list of snippets from the specified snippets paths.
- Show-PAFSnippetMenu: Displays the main menu of snippets to the user.

The PAF main menu allows users to view snippets by categories, search for snippets, and execute chosen snippets.

The PAF will keep running until the user decides to exit manually.

.LINK
https://github.com/voytas75/PowershellFramework
The GitHub repository for the PowerShell Awesome Framework (replace with the actual repository URL).

#>
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

            Show-PAFSnippetMenu -UserSnippets $usersnippetsPath -SystemSnippets $systemsnippetsPath -frameworkPrefix $frameworkPrefix
        }
    }
    catch {
        Write-Error "Error in Start-PAF: $_"
    }
}

# Function to display the PowerShell Awesome Framework banner
function Get-Banner {
    param (
        
    )
    
    $banner = get-content -Path "${PSScriptRoot}\images\banner.txt"
    Write-Output $banner
    return

}

# Save the current TLS security protocol to restore it later
$oldProtocol = [Net.ServicePointManager]::SecurityProtocol

# Switch to using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get the name of the current module
$ModuleName = "PAF"

# Get the installed version of the module
$ModuleVersion = [version]"0.2.0"

# Find the latest version of the module in the PSGallery repository
$LatestModule = Find-Module -Name $ModuleName -Repository PSGallery

try {
    if ($ModuleVersion -lt $LatestModule.Version) {
        Write-Host "An update is available for $($ModuleName). Installed version: $($ModuleVersion). Latest version: $($LatestModule.Version)." -ForegroundColor Red
    } 
    <#     else {
        Write-Host "The $($ModuleName) module is up-to-date."
    }
 #>
}
catch {
    Write-Error "An error occurred while checking for updates: $_"
}

# Restore the original TLS security protocol
[Net.ServicePointManager]::SecurityProtocol = $oldProtocol

# Create fingerprint
#..\helpers\moduleFingerprint.ps1