# `PAF` PowerShell Awesome Framework module - release notes

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.5] - 2023.08.09

### Added

- add `bye bye` on exit

### Changed

- [#11](https://github.com/voytas75/PowershellFramework/issues/11)
- [#12](https://github.com/voytas75/PowershellFramework/issues/12)
- [#13](https://github.com/voytas75/PowershellFramework/issues/13)
- [#18](https://github.com/voytas75/PowershellFramework/issues/18)
- [#19](https://github.com/voytas75/PowershellFramework/issues/19)
- fix for `ShowExampleSnippets` type in config
- fix the order of loading config
- fix snippets' cache

## [0.2.4] - 2023.08.05

### Added

- auto create `config` folder

### Changed

- tls line.

## [0.2.3] - 2023.08.04

### Added

- improve performance.
- snippet function output margins and captions.
- example snippet functions in `snippets\core`

### Changed

- [#9](https://github.com/voytas75/PowershellFramework/issues/9).
- [#8](https://github.com/voytas75/PowershellFramework/issues/8).
- [#3](https://github.com/voytas75/PowershellFramework/issues/3).

## [0.2.2] - 2023.08.03

### Added

- n/a

### Changed

- snippet template
- deleted an unnecessary `snippets\user` folder
- [#5](https://github.com/voytas75/PowershellFramework/issues/5)
- [#7](https://github.com/voytas75/PowershellFramework/issues/7)
- [#8](https://github.com/voytas75/PowershellFramework/issues/8)

## [0.2.1] - 2023.08.02

### Added

- snippet template

### Changed

- removed `config.json`

## [0.2.0] - 2023.08.02

### Added

- search functionality
- save configuration settings
- `Write-ErrorLog`
- inline help for functions
- `Load-Snippets`

### Changed

- improved `Show-PAFSnippetMenu` with better error handling and comments
- improved `Get-PAFScriptBlockInfo` with better error handling
- way of creating `config.json`
- user snippet path
- remove "_" from prefix [#2](https://github.com/voytas75/PowershellFramework/issues/2)
- move `ReleasesNotes.md` to `docs`

## [0.1.3] - 2023.07.31

### Added

- version check

### Changed

- n/a

## [0.1.2] - 2023.07.31

### Added

- n/a

### Changed

- link to icon

## [0.1.1] - 2023.07.31

### Added

- n/a

### Changed

- use `$PSScriptRoot`
- cleaning folder structure
- name to `PAF`

## [0.1.0] - 2023.07.30

### Added

- `Get-PAFScriptBlockName`
- show menu after invoke snippet script
- Support for no catagory and function name
- `Get-Banner`

### Changed

- snippet req. for PAF
- no recurse on `Show-PAFSnippetMenu`
- merged functions

## [0.0.4] - 2023.07.28

### Added

- `Start-PAF`

### Changed

- system snippets path
- get config path data
- `Show-PAFSnippetMenu`
- merge read snippets to one function `Get-PAFSnippets`

## [0.0.3] - 2023.07.22

### Added

- `Get-PAFDefaultConfiguration`

### Changed

- n/a

## [0.0.2] - 2023.07.21

### Added

- `ScriptsToProcess`

### Changed

- storing `$PSScriptRoot` in config file.
- function names.

## [0.0.1] - 2023.07.17

### Added

- Initializing project

### Changed
