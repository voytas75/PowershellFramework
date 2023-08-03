# Documentation

## Folder Descriptions

`snippets/`: The folder that holds all the snippets organized by type.

`snippets/core/`: The folder for core framework snippets.

`$([Environment]::GetFolderPath("MyDocuments"))\PowerShell Awesome Framework\user_snippets\`: The folder for user-specific custom snippets.

`docs/`: The folder containing the documentation files for the project.

`docs/images/`: The folder to store images used in the documentation.

`config.json`: The JSON configuration file for storing settings and metadata of the framework.

`PAF.psm1`: The main PowerShell module file containing the framework functions.

`LICENSE`: The license file specifying the project's open-source license (e.g., MIT License).

**Note:** You may include additional folders for testing, scripts, or any other project-specific content as needed.

Remember to update the folder structure based on your project's actual requirements and functionalities. Also, make sure to add content to the files and folders as you build and develop your project.

This folder structure is just a starting point, and you can customize it to suit your preferences and the needs of your PowerShell Awesome Framework project on GitHub. Happy coding! 🚀😊

## config.json

The "config.json" file contains the configuration settings and metadata for the PowerShell Awesome Framework. It uses the JSON format to store the data in a structured manner. Below is the logic of the "config.json" file:

```json
{
  "FrameworkName": "PowerShell Awesome Framework",
  "DefaultModulePath": "C:\\Path\\To\\Modules",
  "UserSnippetsPath": "C:\\Path\\To\\User\\Snippets",
  "UseColorOutput": true,
  "MaxSnippetsPerPage": 10,
  "ShowBannerOnStartup": true
}
```

**Explanation of Configuration Settings:**

1. `"FrameworkName"`: The name of the PowerShell Awesome Framework. It is a user-friendly name displayed in the menu and other parts of the framework's user interface.

2. `"DefaultModulePath"`: The main path where the core framework snippets are stored. This path is used to load the snippets from the core framework.

3. `"UserSnippetsPath"`: An additional path where users can store their custom snippets. This path is used to load user-specific snippets and allows users to maintain their personalized code separately.

4. `"MaxSnippetsPerPage"`: An integer setting that determines the maximum number of snippets displayed per page in the framework's menu. This setting helps manage the menu layout when there are many snippets.

5. `"ShowBannerOnStartup"`: A boolean setting to control whether to show a startup banner when users load the framework. If set to `true`, the banner will display important information or updates; otherwise, it will not be shown.

**Note:** Ensure that the JSON data in the "config.json" file adheres to the correct JSON syntax. Properly formatted JSON ensures the settings are read correctly by the framework when loading the configuration.

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

## Adding Function Snippets to PowerShell Awesome Module

To prepare a function snippet for adding it to the PowerShell Awesome Module, follow these steps:

1. Create the Snippet File:

   Place the snippet file in one of the following folders:
   - `$PSRootPath\snippets\core\`
   - `$([Environment]::GetFolderPath("MyDocuments"))\PowerShell Awesome Framework\user_snippets\`

   Make sure the snippet file has a name with the prefix 'PAF_' followed by the function name. For example: [`PAF_Get-Example.ps1`](/PAF/snippets/core/PAF_Get-Example.ps1)

2. Add Inline Help:

   At the top of the snippet file, include inline help using PowerShell comment-based help format. The help should contain a synopsis and description of the snippet. Leave two empty lines after the help section. Here's an example:

   ```powershell
   <#
   .SYNOPSIS

   Template

   .DESCRIPTION

   Template file to show how to prepare a function snippet for the PowerShell Awesome Module
   #>
   ```

3. Specify Category and Name in Function Body:

   Inside the function body, include special tags `:CATEGORY` and `:NAME` to specify the category and name of the snippet. Use the following format:

   ```powershell
   <#
   :CATEGORY
   put here the name of the category
   :NAME
   Get-Example
   #>
   ```

   Replace `put here the name of the category` with the actual category name, and `Get-Example` with the name of the function that the snippet represents.

4. Ensure Proper Logic:

   Make sure that the snippet contains logic to execute the functionality that the user intends. Test the snippet to ensure it works correctly.

5. Add to PowerShell Awesome Module:

   Once the snippet file is ready, add it to the user snippets folder where it belongs. For example, if the snippet is for a function called `Get-Example`, it would be placed in the `PAF_Get-Example.ps1` file inside the `$([Environment]::GetFolderPath("MyDocuments"))\PowerShell Awesome Framework\user_snippets\` folder.

By following these steps, you can contribute function snippets to the PowerShell Awesome Module effectively. Ensure that your snippets adhere to the guidelines mentioned above for consistency and compatibility with the module.

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