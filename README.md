# PowerShell Awesome Framework

![PowerShell Awesome Framework](https://github.com/voytas75/PowershellFramework/blob/master/images/banerPAF.png?raw=true "PowerShell Awesome Framework")

[![status](https://img.shields.io/badge/status-PROD%20v0.2.0-green)](https://github.com/voytas75/PowershellFramework/blob/master/PAF/ReleaseNotes.md) &nbsp; [![PowerShell Gallery Version (including pre-releases)](https://img.shields.io/powershellgallery/v/PAF)](https://www.powershellgallery.com/packages/PAF) &nbsp; [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PAF)](https://www.powershellgallery.com/packages/PAF)

[![status](https://img.shields.io/badge/status-DEV%20v0.2.1-red)](https://github.com/voytas75/PowershellFramework/blob/master/PAF/ReleaseNotes.md)

## Overview

The [PowerShell Awesome Framework](https://www.powershellgallery.com/packages/PAF) is a versatile and user-friendly PowerShell module that empowers users to streamline their scripting experience with a collection of useful code snippets. This framework is designed to enhance productivity and simplify the execution of various PowerShell tasks, making it a valuable tool for both beginners and experienced PowerShell users.

## Features

1. **Customizable Settings**: The framework includes a JSON configuration file `config.json` that is automatically generated when you run the `Start-PAF` command for the first time. This configuration file allows users to modify settings and personalize the framework's behavior to suit their preferences and workflow. You can easily adjust the framework's options to match your unique coding needs by editing the settings in the config.json file.

2. **User-Specific Snippets:** Store your custom snippets in an additional folder path, distinct from the core framework snippets. This feature allows you to maintain personalized code without affecting the core functionality.

3. **Dynamic Snippet Loading:** The framework dynamically loads snippets from both the main path (specified in the configuration file) and the user-specific snippets folder. Access all available snippets from one centralized location.

4. **Organized Menu System:** The framework presents snippets in a compact and organized menu, categorized based on their functionality. Quickly browse through categories and snippets to find the desired functionality effortlessly.

5. **Pagination for Large Collections:** Manage a large number of snippets efficiently with built-in pagination. Navigate through multiple pages of snippets with ease, enabling access to a vast array of functionalities.

6. **Keyword-Based Search:** Utilize the search functionality to filter snippets based on keywords. Perform quick searches to locate specific snippets within extensive collections.

7. **REMOVED:** *Color Output Option:* Choose your preferred visual representation by enabling or disabling color output in the menu. Adapt the framework to match your terminal settings and preferences.

8. **Startup Banner Option:** Decide whether to display a startup banner when loading the framework. Customize the banner to display essential information or updates.

## Installation and Usage

The module is available on [PowerShell Gallery](https://www.powershellgallery.com/packages/PAF).

```powershell
Install-Module -Name PAF
```

Import module

```powershell
Import-Module -Module PAF
```

To get all commands in installed module including cmdlets, functions and aliases:

```powershell
Get-Command -Module PAF
```

Start framework to load the menu (JSON configuration file `config.json` is automatically generated).

```powershell
Start-PAF
```

Display configuration. Employ the `Get-PAFConfiguration` command to load your custom configuration (JSON configuration file `config.json` is automatically generated).

```powershell
Get-PAFConfiguration
```

Invoke the `Save-PAFConfiguration` command to save configuration (JSON configuration file `config.json` is automatically generated).

```powershell
Save-PAFConfiguration
```

## Function snippets

Function snippets can be added to module in two folders:

1. `$PSRootPath\sippets\core\`
2. `$([Environment]::GetFolderPath("MyDocuments"))\PowerShell Awesome Framework\user_snippets\`

Snippet files must meet the following requirements: 

1. Prefix in name of snippet file (i.e. 'PAF_Get-Example.ps1')
2. Inline help at top of file and with two empty line after it:

    ```powershell
    <#
    .SYNOPSIS

    Template

    .DESCRIPTION

    Template file to show how prepare function snippet for PowerShell Awesome Module
    #>
    ```

3. 'category' and 'name' after in function body below function declaration line, as follows:

    ```powershell
    <#
    :CATEGORY
    put here name of categor
    :NAME
    Get-Example
    #>
    ```

4. snippet must have logic execute all what user want to.

Template file [`PAF_Get-Example.ps1`](.\PAF\snippets\user\PAF_Get-Example.ps1) for snippet is in module folder `snippets\user`.

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## Contributing

We welcome contributions from the community! Feel free to submit pull requests, report issues, or suggest new features to make the framework even more powerful and user-friendly.

**Clone the Repository:** Clone the PowerShell Awesome Framework repository to your local machine.

### License

The PowerShell Awesome Framework is released under the [MIT License](https://github.com/voytas75/PowershellFramework/blob/master/LICENSE).

**Contact:**
If you have any questions or need assistance, please feel free to reach out to us via [GitHub Issues](https://github.com/voytas75/PowershellFramework/issues).

Join us on the journey to make PowerShell scripting a truly awesome experience!
