@{
    RootModule        = 'PAF'
    ModuleVersion     = '0.2.1'
    GUID              = 'e91f3cc2-9f21-4373-a2e5-b535b4a9eaea'
    Author            = 'Wojciech Napierala (voytas75)'
    Copyright         = '(c) 2023 Wojciech Napierala. All rights reserved.'
    CompanyName       = 'Script Savvy Ninja'
    Description       = 'The PowerShell Awesome Framework is a versatile and user-friendly PowerShell module that empowers users to streamline their scripting experience with a collection of useful code snippets. This framework is designed to enhance productivity and simplify the execution of various PowerShell tasks, making it a valuable tool for both beginners and experienced PowerShell users.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        "Start-PAF",
        "Get-PAFConfiguration",
        "Save-PAFConfiguration"
    )
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()
    # Variables to export from this module
    VariablesToExport = '*'
    #ScriptsToProcess  = "Set-PAFConfigFile.ps1"
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @(
                "Framework",
                "snippet"

            )
    
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/voytas75/PowershellFramework/blob/master/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/voytas75/PowershellFramework'
    
            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/voytas75/PowershellFramework/master/PAF/images/PAF.PNG'
    
            # ReleaseNotes of this module
            ReleaseNotes = '/docs/ReleaseNotes.md'
    
        } # End of PSData hashtable

    } # End of PrivateData hashtable
    
}
