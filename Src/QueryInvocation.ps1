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
        $Repo,

        [Parameter()]
        [ValidateSet('C#', 'JavaScript', 'Go', 'PowerShell')] # TODO; other languages
        [string]
        $Language,

        [Parameter()]
        [int]
        $PerPage = 20,

        [Parameter()]
        [int]
        $Page = 1
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
            Repo = $Repo
            Org = $Org
            PerPage = $PerPage
            Page = $Page
        }
        $uri = "https://api.github.com/search/code?{0}" -f (Get-GithubCodeSearchQueryString @searchParameters)

        $results = Invoke-RestMethod -Uri $uri -Headers $headers

        $results.items | ForEach-Object {
            $matches = $_.text_matches | ForEach-Object { $_.fragment }

            [pscustomobject]@{
                Matches = $matches
                URL = $_.html_url
            }
        }
    }
}

function Get-GithubCodeSearchQueryString {
    param (
        $Text,
        $Org,
        $Repo,
        $Language,
        $PerPage,
        $Page
    )

    $query = "q=$Text"

    if ($Org) {
        $query += "+org:$Org"
    }

    if ($Repo) {
        $query += "+repo:$Repo"
    }

    if ($Language) {
        $query += '+language:{0}' -f [Uri]::EscapeDataString($Language) # 'C#' must be escaped
    }

    if ($PerPage) {
        $query += "&per_page=$PerPage"
    }

    if ($Page) {
        $query += "&page=$Page"
    }

    $query
}
