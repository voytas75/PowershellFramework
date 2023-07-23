# Define the data as a custom PowerShell object
$frameworkData = [PSCustomObject]@{
    "FrameworkName"       = "PowerShell Awesome Framework"
    "DefaultModulePath"   = "${PSScriptRoot}"
    "SnippetsPath"        = "${PSScriptRoot}\snippets\core"
    "UserSnippetsPath"    = "${PSScriptRoot}\Snippets\user"
    "UseColorOutput"      = $true
    "MaxSnippetsPerPage"  = 10
    "ShowBannerOnStartup" = $true
    "FrameworkPrefix"     = "PAF_"
}

# Convert the custom object to JSON
$jsonData = $frameworkData | ConvertTo-Json -Depth 4

# Specify the path where you want to save the JSON file
$jsonFilePath = "${PSScriptRoot}\config.json"

# Write the JSON data to the file
$jsonData | Out-File -FilePath $jsonFilePath

# Output a message indicating successful creation
Write-Host "JSON file created successfully at: $jsonFilePath"
