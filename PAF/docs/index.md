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

You can use the `Get-Content` and `ConvertFrom-Json` cmdlets in PowerShell to read and load the `config.json` file into a PowerShell object. This object can be used to access and utilize the configuration settings throughout the PowerShell Awesome Framework code.

For example, to read the `config.json` file:

```powershell
$configFilePath = "C:\Path\To\Config\config.json"
$configData = Get-Content -Path $configFilePath | ConvertFrom-Json
```

Once loaded, you can access specific configuration settings as follows:

```powershell
$frameworkName = $configData.FrameworkName
$defaultModulePath = $configData.DefaultModulePath
$userSnippetsPath = $configData.UserSnippetsPath
$maxSnippetsPerPage = $configData.MaxSnippetsPerPage
$showBannerOnStartup = $configData.ShowBannerOnStartup
```

With the configuration settings loaded, you can now use them within the PowerShell Awesome Framework functions and customize the framework behavior based on these settings.

Remember to update the configuration file with appropriate paths and settings based on your project's requirements.

I hope this clarifies the logic and usage of the `config.json` file in your PowerShell Awesome Framework. Happy coding! 🚀😊
