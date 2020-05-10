# Github Code Search

![CI](https://github.com/charliebillen/GithubCodeSearch/workflows/CI/badge.svg)

Provides a wrapper around the GitHub code search API to quickly search for code from the command line.

Code can be searched for by language and within specified repositories or organisations (your access token must have access to them).

## Installation
The module depends on `ConvertBase64Strings`, which can be found at [charliebillen/ConvertBase64Strings](https://github.com/charliebillen/ConvertBase64Strings), and will be installed automatically if installing from PSGallery.

### Install the module from PSGallery
```powershell
Install-Module -Name GithubCodeSearch
```

### Set up your GitHub credentials
Create a personal access token by following the instructions [here](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line), it must have repository access and if you want to search within an organisation it must have access to that organisation.

Once you have a token you can issue the following command to store it in configuration, it will be combined with the provided username and stored in `$HOME\.githubcodesearch_token` as a Base64 encoded string.

```powershell
Set-GithubCodeSearchToken -Username xxx -Token yyy
```

## Usage

Search for code containing the text `if`:
```powershell
Invoke-GithubCodeSearch -Text if
```

Search for PowerShell code containing the text `if`:
```powershell
Invoke-GithubCodeSearch -Text if -Language powershell
```

Search for code in this repository containing the text `if`:
```powershell
Invoke-GithubCodeSearch -Text if -Repo charliebillen/GithubCodeSearch
```

Search for code in the `TheDreadPirateRoberts` organisation containing the text `if`:
```powershell
Invoke-GithubCodeSearch -Text if -Org TheDreadPirateRoberts
```

You can run `Get-Help Invoke-GithubCodeSearch` for more examples.

The results can be pipelined for further processing, to `Format-List` for display for example:
```powershell
Invoke-GithubCodeSearch -Text if -Org TheDreadPirateRoberts | Format-List
```

Or to `Foreach-Object` to open the first result in a browser:
```powershell
Invoke-GithubCodeSearch -Text if -Org TheDreadPirateRoberts -PerPage 1 | ForEach-Object { Start-Process $_.URL }
```
