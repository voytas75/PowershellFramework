# PowerShell Awesome Framework

![PowerShell Awesome Framework](https://github.com/voytas75/PowershellFramework/blob/master/images/banerPAF.png?raw=true "PowerShell Awesome Framework")

[![status](https://img.shields.io/badge/status-PROD-green)](https://github.com/voytas75/PowershellFramework/blob/master/powershell-awesome-framework/ReleaseNotes.md)

## Overview

The PowerShell Awesome Framework is a versatile and user-friendly PowerShell module that empowers users to streamline their scripting experience with a collection of useful code snippets. This framework is designed to enhance productivity and simplify the execution of various PowerShell tasks, making it a valuable tool for both beginners and experienced PowerShell users.

## Features

1. **Customizable Settings:** The framework includes a JSON configuration file (`config.json`) where users can modify settings to suit their preferences and workflow. Personalize the framework's behavior to match your unique coding needs.

2. **User-Specific Snippets:** Store your custom snippets in an additional folder path, distinct from the core framework snippets. This feature allows you to maintain personalized code without affecting the core functionality.

3. **Dynamic Snippet Loading:** The framework dynamically loads snippets from both the main path (specified in the configuration file) and the user-specific snippets folder. Access all available snippets from one centralized location.

4. **Organized Menu System:** The framework presents snippets in a compact and organized menu, categorized based on their functionality. Quickly browse through categories and snippets to find the desired functionality effortlessly.

5. **Pagination for Large Collections:** Manage a large number of snippets efficiently with built-in pagination. Navigate through multiple pages of snippets with ease, enabling access to a vast array of functionalities.

6. **TODO:** *Keyword-Based Search:* Utilize the search functionality to filter snippets based on keywords. Perform quick searches to locate specific snippets within extensive collections.

7. **REMOVED:** *Color Output Option:* Choose your preferred visual representation by enabling or disabling color output in the menu. Adapt the framework to match your terminal settings and preferences.

8. **Startup Banner Option:** Decide whether to display a startup banner when loading the framework. Customize the banner to display essential information or updates.

## Usage

1. **Stat framework:** Use the `Start-PAF`to load the framework menu.

2. **Display configuration:** Employ the `Get-PAFConfiguration` command to load your custom configuration.

3. **Save configuration:** Invoke the `Save-PAFConfiguration` command to save configuration.

## Getting Started

1. **Clone the Repository:** Clone the PowerShell Awesome Framework repository to your local machine.

2. **Modify Configuration:** Customize the `config.json` file to match your preferred settings, including the paths for core snippets and user-specific snippets.

3. **Load the Framework:** Import the framework module into your PowerShell session using `Import-Module` and get started with your scripting journey.

4. **Stat framework:** Use the `Start-PAF`to load the framework menu.

### Contributing

We welcome contributions from the community! Feel free to submit pull requests, report issues, or suggest new features to make the framework even more powerful and user-friendly.

### License

The PowerShell Awesome Framework is released under the [MIT License](https://github.com/voytas75/PowershellFramework/blob/master/LICENSE).

**Contact:**
If you have any questions or need assistance, please feel free to reach out to us via [GitHub Issues](https://github.com/voytas75/PowershellFramework/issues).

Join us on the journey to make PowerShell scripting a truly awesome experience!
