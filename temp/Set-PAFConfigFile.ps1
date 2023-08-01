try {
    $documentsFolder = [Environment]::GetFolderPath("MyDocuments")
    $newUserSnippetsPath = Join-Path $documentsFolder 'PowerShell Awesome Framework\user_snippets'
    
    if (-not (Test-Path -Path $newUserSnippetsPath -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $newUserSnippetsPath | Out-Null
    }
    # Define the data as a custom PowerShell object
    $frameworkData = [PSCustomObject]@{
        "FrameworkName"       = "PowerShell Awesome Framework"
        "DefaultModulePath"   = $PSScriptRoot
        "SnippetsPath"        = "${PSScriptRoot}\snippets\core"
        "UserSnippetsPath"    = $newUserSnippetsPath
        "MaxSnippetsPerPage"  = 10
        "ShowBannerOnStartup" = $true
        "FrameworkPrefix"     = "PAF_"
    }
    
    # Convert the custom object to JSON
    $jsonData = $frameworkData | ConvertTo-Json -Depth 4
    
    # Specify the path where you want to save the JSON file
    $jsonFilePath = "${PSScriptRoot}\config.json"
    
    # Write the JSON data to the file
    $jsonData | Out-File -FilePath $jsonFilePath -Force
    
    # Output a message indicating successful creation
    Write-Verbose "JSON file created successfully at: $jsonFilePath"
    
}
catch {
    Write-Error "Error creating JSON configuration file: $_"
    return $null
}