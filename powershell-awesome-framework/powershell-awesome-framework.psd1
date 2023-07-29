@{
    RootModule        = 'powershell-awesome-framework'
    ModuleVersion     = '0.0.4'
    GUID              = 'e91f3cc2-9f21-4373-a2e5-b535b4a9eaea'
    Author            = 'Wojciech Napierala (voytas75)'
    Copyright         = '(c) 2023 Wojciech Napierala. All rights reserved.'
    CompanyName       = 'Script Savvy Ninja'
    Description       = 'Description of your module'
    PowerShellVersion = '5.1'
    FunctionsToExport = '*'
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()
    # Variables to export from this module
    VariablesToExport = '*'
    ScriptsToProcess  = "Set-PAFConfigFile.ps1"
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @(
                "Framework"
            )
    
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/voytas75/PowershellFramework/blob/master/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/voytas75/PowershellFramework'
    
            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/voytas75/PowershellFramework/master/powershell-awesome-framework/images/PAF.PNG'
    
            # ReleaseNotes of this module
            # ReleaseNotes = 'ReleaseNotes.md'
    
        } # End of PSData hashtable

    } # End of PrivateData hashtable
    
}
