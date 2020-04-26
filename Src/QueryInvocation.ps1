. $PSScriptRoot\TokenManagement.ps1

function Invoke-GithubCodeSearch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Text,

        [Parameter()]
        [string]
        $Org,

        [Parameter()]
        [string]
        $Repository,

        [Parameter()]
        [validateset('C#', 'JavaScript', 'Go', 'PowerShell')] # TODO; other languages
        [string]
        $Language
    )

    begin {
        $headers = @{
            'Authorization' = "Basic $(Get-GithubCodeSearchToken)"
            'Accept' = 'application/vnd.github.v3.text-match+json'
        }
    }

    process {
        $searchParameters = @{
            Text = $Text
            Language = $Language
            Repository = $Repository
            Org = $Org
        }
        $uri = "https://api.github.com/search/code?{0}" -f (Get-GithubCodeSearchQueryString @searchParameters)

        $results = Invoke-RestMethod -Uri $uri -Headers $headers

        # TODO: paging of results
        $results.items | ForEach-Object {
            $matches = $_.text_matches | ForEach-Object { $_.fragment }

            [pscustomobject]@{
                Matches = $matches
                URL = $_.html_url
            }
        }
    }
}

function Get-GithubCodeSearchQueryString($Text, $Org, $Repository, $Language) {
    $query = "q=$Text"

    if ($Org) {
        $query += "+org:$Org"
    }

    if ($Repository) {
        $query += "+repo:$Repository"
    }

    if ($Language) {
        $query += "+language:{0}" -f [Uri]::EscapeDataString($Language) # 'C#' must be escaped
    }

    $query
}
