@{
    ModuleVersion     = '1.0'
    GUID              = 'e91f3cc2-9f21-4373-a2e5-5e3c8357d55d'
    Author            = 'Wojciech Napierała (voytas75)'
    CompanyName       = 'Script Savvy Ninja'
    Description       = 'Description of your module'
    PowerShellVersion = '5.1'
    FunctionsToExport = '*'
    ModuleToProcess   = 'powershell-awesome-framework.psm1'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @(
                "Framework",
                "SystemAdministration"
            )
    
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/voytas75/PowershellFramework/blob/master/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/voytas75/PowershellFramework'
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = 'ReleaseNotes.md'
    
        } # End of PSData hashtable

    } # End of PrivateData hashtable
    
}
