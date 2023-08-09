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

    .LINK
    https://github.com/voytas75/PowershellFramework
    The GitHub repository for the PowerShell Awesome Framework.
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
    - ShowExampleSnippet: A boolean value indicating whether showing the example snippet.

    To customize the configuration, manually edit the values in the config.json file using a text editor.

    .LINK
    https://github.com/voytas75/PowershellFramework
    The GitHub repository for the PowerShell Awesome Framework.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$ConfigFilePath
    )

    try {
        # If ConfigFilePath is not specified, use the default path (same directory as the script)
        if (-not $ConfigFilePath) {
            $ConfigFilePath = Join-Path $PSScriptRoot 'config\config.json'
        }

        # Check if the configuration folder exists
        if (-not (Test-Path (Join-Path $PSScriptRoot 'config'))) {
            # Create the configuration file with default values
            [void](New-Item -Path (Join-Path $PSScriptRoot 'config') -ItemType Directory)
            Write-Host "Configuration folder created at '$(Join-Path $PSScriptRoot 'config')'."
        }


        # Check if the configuration file exists
        if (-not (Test-Path $ConfigFilePath)) {
            # Create the configuration file with default values
            $defaultConfigData = Get-PAFDefaultConfiguration
            $defaultConfigData | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigFilePath -Encoding UTF8
            Write-Host "Configuration file created at '$ConfigFilePath'."
        }

        # Read the content of the configuration file and convert it to a JSON object
        $ConfigData = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json

        # Add the ConfigPath property to the object
        #$ConfigData | Add-Member -NotePropertyName "ConfigPath" -NotePropertyValue $ConfigFilePath
        # Check if the function was invoked from a script or directly from the console
        #Write-verbose "MyInvocation.InvocationName: $($MyInvocation | out-string)" -verbose
        if ($MyInvocation.CommandOrigin -eq "Runspace") {
            # The function was called directly from the console
            Write-Information -MessageData "Config path: '$ConfigFilePath'" -InformationAction Continue
        }
        #else {
        #    # The function was called from a script or another function
        #    Write-Host "Function executed from a script or another function."
        #}
        return $ConfigData
    }
    catch {
        Write-Error "Error reading or parsing the configuration file: $_"
        return $null
    }
}

# Function to test if required properties are present in an object
function Test-PAFRequiredProperty {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Object,

        [Parameter(Mandatory = $false)]
        [string[]]$Property,

        [string]$Setting
    )

    process {
        if ($null -eq $Setting) {
            foreach ($prop in $Property) {
                if (-not $Object.PSObject.Properties.Name.Contains($prop)) {
                    #Write-Error "Required property '$prop' not found in the object."
                    return $false
                }
            }
    
        }
        else {
            if (-not $Object.PSObject.Properties.Name.Contains($Setting)) {
                #Write-Error "Required property '$Setting' not found in the object."
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
    <#
    .SYNOPSIS
    Get the default configuration settings for the PowerShell Awesome Framework (PAF).

    .DESCRIPTION
    This function retrieves the default configuration settings for the PowerShell Awesome Framework (PAF). These settings are used when a configuration file is not found or when required properties are missing in the file. The function returns a hashtable containing various default configuration options.

    .EXAMPLE
    $defaultConfig = Get-PAFDefaultConfiguration

    Retrieves the default configuration settings for PAF.

    .OUTPUTS
    Hashtable
    Returns a hashtable representing the default configuration data.

    .NOTES
    The default configuration includes the following properties:
    - FrameworkName: The name of the PowerShell Awesome Framework.
    - DefaultModulePath: The default path where PAF is installed.
    - SnippetsPath: The path to the core snippets directory.
    - UserSnippetsPath: The path to the user-specific snippets directory.
    - MaxSnippetsPerPage: The maximum number of snippets displayed per page in the snippet menu.
    - ShowBannerOnStartup: A boolean value indicating whether to show the PAF banner on startup.
    - FrameworkPrefix: The prefix used to identify PAF-specific snippets.
    - ShowExampleSnippets: A boolean value indicating whether to show the example snippets.
    
    Additional configuration options can be added to the hashtable as needed.

    .LINK
    https://github.com/voytas75/PowershellFramework
    The GitHub repository for the PowerShell Awesome Framework.
    #>
    # Define default values for the configuration options
    $documentsFolder = [Environment]::GetFolderPath("MyDocuments")
    $newUserSnippetsPath = Join-Path $documentsFolder 'PowerShell Awesome Framework\user_snippets'

    # Ensure the user-specific snippets directory exists
    if (-not (Test-Path -Path $newUserSnippetsPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $newUserSnippetsPath | Out-Null
    }

    # Create and return the default configuration hashtable
    return @{
        "FrameworkName"       = "PowerShell Awesome Framework"
        "DefaultModulePath"   = $PSScriptRoot
        "SnippetsPath"        = Join-Path $PSScriptRoot 'snippets\core'
        "UserSnippetsPath"    = $newUserSnippetsPath
        "MaxSnippetsPerPage"  = 10
        "ShowBannerOnStartup" = $true
        "FrameworkPrefix"     = "PAF"
        "ShowExampleSnippets" = $true
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

    .PARAMETER SettingValue
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

    .LINK
    https://github.com/voytas75/PowershellFramework
    The GitHub repository for the PowerShell Awesome Framework.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$configFilePath,

        [Parameter(Mandatory = $false)]
        [object]$configData,

        [string]$settingName = $null,

        [array]$settingValue = $null,

        [string]$encoding = 'UTF8'
    )
  
    try {
        # If no parameters are provided, display instructions on how to use the function
        if (-not $PSBoundParameters.GetEnumerator().MoveNext()) {
            Write-Host "To save an individual setting, use the following command:"
            Write-Host "Save-PAFConfiguration -SettingName '<SettingName>'"

            Write-Host "`nTo display settings and values:"
            Write-Host "Get-PAFConfiguration"

            Write-Host "`nTo get more help:"
            Write-Host "Get-Help Save-PAFConfiguration"
            
            return
        }

        if (-not $configFilePath) {
            $configFilePath = "${PSScriptRoot}\config\config.json"
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
            if (($validSettings -contains $settingName) -and ($null -eq $settingValue[0])) {
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
            elseif ($null -ne $settingValue[0]) {
                # Update the value of the setting in the configuration data
                if (-not(Test-PAFRequiredProperty -Object $configData -Setting $settingName)) {
                    $configData | Add-Member -MemberType NoteProperty -Name $settingName -Value $settingValue[0]
                    Write-Information "Adding '$settingName' updated with value '$($settingValue[0])' and saved to '$configFilePath'." -InformationAction Continue
                }
                else {
                    $configData.$settingName = $settingValue[0]
                    Write-Information "Setting '$settingName' updated with new value '$($settingValue[0])' and saved to '$configFilePath'." -InformationAction Continue
                }
    
                # Save the entire updated configuration data to the configuration file
                $jsonConfig = $configData | ConvertTo-Json -Depth 10
    
                # Save the JSON data to the configuration file
                $jsonConfig | Set-Content -Path $configFilePath -Encoding $encoding
    

                return
            }
            else {
                Write-Error "Setting '$settingName' not found in the configuration data."
                return Get-PAFDefaultConfiguration

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

                $snippetDescription = ""
                if ($null -ne $metadata.Description) {
                    $snippetDescription = $metadata.Description.ToString()
                } 

                $snippetMetadata = [PSCustomObject]@{
                    'Name'        = $functionName
                    'Synopsis'    = $metadata.Synopsis.trimEnd()
                    'Description' = $snippetDescription
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

# Define a helper function to load snippets from a given path
function Load-Snippets {
    param (
        [string]$Path
    )
            
    if (Test-Path -Path $Path) {
        Get-PAFSnippets -SnippetsPath $Path -FrameworkPrefix $FrameworkPrefix
    }
    else {
        Write-Warning "Invalid snippets path: $Path"
        return @()
    }
}

        
# Improved Show-PAFSnippetMenu with better error handling and comments
# Function to display the menu for executing selected snippets
function Show-PAFSnippetMenu {
    <#
    .SYNOPSIS
    Display the main menu for the PowerShell Awesome Framework (PAF) snippets.

    .DESCRIPTION
    This function displays the main menu for the PowerShell Awesome Framework (PAF) snippets.
    The user can choose to browse snippets by categories, search for snippets, or exit the menu.

    .PARAMETER SearchKeywords
    Optional. Search keywords to find snippets. If provided, the menu will display matched snippets based on the keywords.

    .EXAMPLE
    Show-PAFSnippetMenu

    Display the main menu for browsing and searching snippets.

    .EXAMPLE
    Show-PAFSnippetMenu -SearchKeywords "example"

    Display snippets that match the search keywords "example".

    .NOTES
    The Show-PAFSnippetMenu function uses the following helper functions to perform its tasks:
    - Get-PAFSnippets: Retrieves the list of snippets from the specified snippets paths.
    - Show-PAFSnippetExecutionMenu: Displays the menu for executing selected snippets.
    - Convert-FirstLetterToUpper: Helper function to capitalize the first letter of a string.

    The menu will keep running until the user decides to exit manually.

    .LINK
    https://github.com/voytas75/PowershellFramework
    The GitHub repository for the PowerShell Awesome Framework.
    #>

    [CmdletBinding()]
    param (
        [string]$SearchKeywords = $null,
        [string]$FrameworkPrefix
    )

    try {
        $usersnippetsPath = (Get-PAFConfiguration).UserSnippetsPath
        $systemsnippetsPath = (Get-PAFConfiguration).SnippetsPath

        # Load snippets based on the search criteria or return all snippets
        if ($SearchKeywords) {
            <#             $allSnippets = @(
                (Load-Snippets -Path $usersnippetsPath),
                (Load-Snippets -Path $systemsnippetsPath)
            )
 #>         
            if ($script:cachedSnippets.Length -gt 0) {
                $allSnippets = $script:cachedSnippets
            }
            else {
                $allSnippets += (Load-Snippets -Path $usersnippetsPath)
                $allSnippets += (Load-Snippets -Path $systemsnippetsPath)
            }

            $matchedSnippets = $allSnippets | Where-Object {
                $_.Name -like "*$SearchKeywords*" -or $_.Synopsis -like "*$SearchKeywords*" -or $_.Description -like "*$SearchKeywords*"
            }

            if ($matchedSnippets.Count -eq 0) {
                Write-Host "No snippets found matching the search keywords '$SearchKeywords'."
                return
            }
            else {
                Show-PAFSnippetExecutionMenu -Snippets $matchedSnippets
                return
            }
        }
        else {
            # Show a menu for category selection
            <#             $categories = @(
                (Load-Snippets -Path $usersnippetsPath | Select-Object -ExpandProperty Category -Unique),
                (Load-Snippets -Path $systemsnippetsPath | Select-Object -ExpandProperty Category -Unique)
            )
            #>
            $categories = @()
            if ($script:cachedSnippets.Length -gt 0) {
                $categories = ($script:cachedSnippets | Select-Object -ExpandProperty Category -Unique)
            }
            else {
                $categories += (Load-Snippets -Path $usersnippetsPath)
                $categories += (Load-Snippets -Path $systemsnippetsPath)
                $categories = $categories | Select-Object -ExpandProperty Category -Unique
            }            

            if ($categories.Count -eq 0) {
                Write-Host "No categories found. Continuing without category selection."
                return
            }

            [array]$categorySelection = $categories | ForEach-Object { $_ }
            $categorySelection += "All Categories"

            do {
                Write-Host "Main Menu - Available Options:"
                Write-Host "1. Browse snippets by category"
                Write-Host "2. Search for snippets"
                Write-Host "3. Exit"

                $menuChoice = Read-Host "Enter the number corresponding to your choice"

                switch ($menuChoice) {
                    1 {
                        $Category = Show-PAFCategorySelectionMenu -CategorySelection $categorySelection
                        if ($Category -eq "All Categories") {
                            <# $allSnippets = @(
                                (Load-Snippets -Path $usersnippetsPath),
                                (Load-Snippets -Path $systemsnippetsPath)
                            ) #>
                            $allSnippets = @()
                            if ($script:cachedSnippets -eq 0) {
                                
                                $allSnippets += (Load-Snippets -Path $usersnippetsPath)
                                $allSnippets += (Load-Snippets -Path $systemsnippetsPath)
                            }
                            else {
                                $allSnippets = $script:cachedSnippets
                            }
                            if ((Show-PAFSnippetExecutionMenu -Snippets $allSnippets) -eq "x") {
                                #$Category = Show-PAFCategorySelectionMenu -CategorySelection ([array]$categorySelection)
                            }
                        }
                        else {
                            <#                             $categorySnippets = @(
                                (Load-Snippets -Path $usersnippetsPath | Where-Object { $_.Category -eq $Category }),
                                (Load-Snippets -Path $systemsnippetsPath | Where-Object { $_.Category -eq $Category })
                            ) #>
                            $categorySnippets = @()
                            $categorySnippets += (Load-Snippets -Path $usersnippetsPath)
                            $categorySnippets += (Load-Snippets -Path $systemsnippetsPath)
                            $categorySnippets = $categorySnippets | Where-Object { $_.Category -eq $Category }

                            if ($categorySnippets.Count -eq 0) {
                                Write-Host "No snippets found in the '$Category' category."
                            }
                            else {
                                
                                if ((Show-PAFSnippetExecutionMenu -Snippets $categorySnippets) -eq "x") {
                                    #$Category = Show-PAFCategorySelectionMenu -CategorySelection ([array]$categorySelection)
                                }
    
                            }
                        }
                        break
                    }
                    2 {
                        $searchKeywords = Read-Host "Enter search keywords to find snippets"
                        Show-PAFSnippetMenu -SearchKeywords $searchKeywords -FrameworkPrefix $FrameworkPrefix
                        break
                    }
                    3 {
                        Write-Host "bye bye" -ForegroundColor Green
                        return 3
                    }
                    default {
                        Write-Warning "Invalid menu choice. Please select a valid option."
                    }
                }
            } while ($menuChoice -ne 3)
        }
    }
    catch {
        Write-Error "An error occurred in Show-PAFSnippetMenu: $_"
    }
}

function Show-PAFCategorySelectionMenu {
    param (
        [Parameter(Mandatory = $true)]
        [array]$CategorySelection
    )

    do {
        Write-Host "Available Categories:"
        for ($i = 0; $i -lt $CategorySelection.Count; $i++) {
            Write-Host "$($i + 1). $($CategorySelection[$i])"
        }

        $menuChoice = Read-Host "Enter the number corresponding to your choice"

        if ($menuChoice -ge 1 -and $menuChoice -le $CategorySelection.Count) {
            $selectedCategory = $CategorySelection[$menuChoice - 1]
            return $selectedCategory
        }
        else {
            Write-Warning "Invalid menu choice. Please select a valid category."
        }
    } while ($true)
}

function Show-PAFSnippetExecutionMenu {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Snippets
    )

    do {
        Write-Host "Available Snippets:"
        for ($i = 0; $i -lt $Snippets.Count; $i++) {
            # wow! only write-host displays; write-output do not!
            #Write-Output "$($i + 1). $($Snippets[$i].Name) - $($Snippets[$i].Synopsis)"
            Write-Host "$($i + 1). $($Snippets[$i].Name) - $($Snippets[$i].Synopsis)"
        }
        Write-Host "X. Go back to the main menu"
        $menuChoice = Read-Host "Enter the number corresponding to the snippet to execute or 'X' to go back"

        if (-not ($menuChoice -eq "X" -or $menuChoice -eq "x")) {
            [int]$menuChoice
        }

        if ($menuChoice -ge 1 -and ($menuChoice -le $($Snippets.Count))) {
            $selectedSnippet = $Snippets[$menuChoice - 1]
            Clear-Host
            Write-Host "Executing snippet: $($selectedSnippet.Name)`nPath: '$($selectedSnippet.Path)'`nDescription: '$($selectedSnippet.Description)'`n" -ForegroundColor DarkGreen
            Write-Host "Start of snippet`n`n" -ForegroundColor DarkBlue
            #return (Invoke-Expression $selectedSnippet.Path)
            Invoke-Expression "& { . '$($selectedSnippet.Path)' }" -OutVariable snippetOutput
            write-host ($snippetOutput | out-string)
            Write-Host "`nEnd of snippet`n" -ForegroundColor DarkBlue
            
        }
        elseif ($menuChoice -eq "X" -or $menuChoice -eq "x") {
            return $menuChoice
        }
        else {
            Write-Warning "Invalid menu choice. Please select a valid snippet or 'X' to go back."
        }
    } while ($true)
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
                return $functionName.trimEnd()
            }
            "Category" {
                return (Convert-PAFFirstLetterToUpper -InputString $category).trimEnd()
                #return $category
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

function Convert-PAFFirstLetterToUpper {
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
The GitHub repository for the PowerShell Awesome Framework.
#>
    try {

        $configData = Get-PAFConfiguration
        if ($null -eq $configData) {
            Write-Error "Failed to load configuration. Exiting PAF."
            return
        }

        # Add missing settings to config
        $configdataDefault = Get-PAFDefaultConfiguration
        #$requiredProperties = @("FrameworkName", "DefaultModulePath", "SnippetsPath", "UserSnippetsPath", "MaxSnippetsPerPage", "ShowBannerOnStartup", "FrameworkPrefix", "ShowExampleSnippets")
        $requiredProperties = [array]($configdataDefault.Keys)

        foreach ($configDataItem in $requiredProperties) {
            # if no key in config then add it with default value
            # Check if all required properties are present in the configuration data
            if (-not (Test-PAFRequiredProperty -Object $ConfigData -Setting $configDataItem )) {
                Write-Information "Missing required property '$configDataItem'. Using default value '$($configdataDefault[$configDataItem])'." -InformationAction Continue
                Save-PAFConfiguration -settingName $configDataItem -settingValue ([array]$($configdataDefault[$configDataItem]))
            }

        }

        $usersnippetsPath = $configData.UserSnippetsPath
        $systemsnippetsPath = $configData.SnippetsPath
        $frameworkPrefix = $configData.FrameworkPrefix

        if ($configData.ShowBannerOnStartup -and $null -eq $bannerShowed ) {
            Get-PAFBanner
            $bannerShowed = $true
        }

        while ($exitSnippetMenu -ne 3) {
            
            if ($script:cachedSnippets.Length -eq 0) {
    
                # Caching snippets to avoid repeated file I/O
                $script:cachedSnippets = @()
                $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $usersnippetsPath -frameworkPrefix $frameworkPrefix)
                if ($configData.ShowExampleSnippets -eq "true") {
                    $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix)
                }
                else {
                    $script:cachedSnippets += (Get-PAFSnippets -snippetsPath $systemsnippetsPath -frameworkPrefix $frameworkPrefix) | Where-Object { $_.category -ne "Example" }
                }
            }
            #Show-PAFSnippetMenu -UserSnippets $usersnippetsPath -SystemSnippets $systemsnippetsPath -frameworkPrefix $frameworkPrefix
            $exitSnippetMenu = Show-PAFSnippetMenu -frameworkPrefix $frameworkPrefix
        }
    }
    catch {
        Write-Error "Error in Start-PAF: $_"
    }
}

# Function to display the PowerShell Awesome Framework banner
function Get-PAFBanner {
    param (
        
    )
    
    $banner = get-content -Path "${PSScriptRoot}\images\banner.txt"
    Write-Output $banner
    return

}

# Save the current TLS security protocol to restore it later
#$oldProtocol = [Net.ServicePointManager]::SecurityProtocol

# Switch to using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
# Get the name of the current module
$ModuleName = "PAF"

# Get the installed version of the module
$ModuleVersion = [version]"0.2.5"

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
#[Net.ServicePointManager]::SecurityProtocol = $oldProtocol

# Create fingerprint
#..\helpers\moduleFingerprint.ps1