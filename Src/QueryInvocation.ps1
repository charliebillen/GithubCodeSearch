. $PSScriptRoot\TokenManagement.ps1

function Invoke-GithubCodeSearch {
    <#
    .SYNOPSIS
    Searches for code on GitHub containing the specified text.

    .DESCRIPTION
    Searches for code on GitHub containing the specified text.

    Searches can optionally be constrained by language, or to a specific repository
    or organisation.  These can be combined, for example to search within  a specific language
    within a specific organisation.

    To search within private repositories or organisations your access token must have been granted
    access to them.

    By default only the first page of 20 results is returned.  This can be overriden, but GitHub's
    API will return at most 300 results per page, and at most 1000 results across all pages.

    The function returns a list of results in the format:
    {
        Matches: ['', ''],
        URL: ''
    }
    Where Matches is up to 2 text snippets showing the found text in context, and URL is a link
    to the file on GitHub.

    The results can be passed through to other functions such as Select-Object, or Format-List for
    further processing.

    .PARAMETER Text
    The text to search for.

    .PARAMETER Language
    The language to search in, e.g. C#, JavaScript.

    .PARAMETER Repo
    The repository to search in.

    .PARAMETER Org
    The organisation to search in.

    .PARAMETER PerPage
    The number of results to return, default 20.

    .PARAMETER Page
    The page of results to return, defaul 1.

    .INPUTS
    String: The text to search for can be taken from the pipeline.

    .OUTPUTS
    System.Array: The array of results

    .EXAMPLE
    Invoke-GithubCodeSearch -Text if

    .EXAMPLE
    Invoke-GithubCodeSearch -Text if -Language powershell

    .EXAMPLE
    Invoke-GithubCodeSearch -Text if -Repo charliebillen/GithubCodeSearch

    .EXAMPLE
    Invoke-GithubCodeSearch -Text if -Org TheDreadPirateRoberts

    .EXAMPLE
    Invoke-GithubCodeSearch -Text if -PerPage 300

    .EXAMPLE
    Invoke-GithubCodeSearch -Text if -Page 10

    .LINK
    https://github.com/charliebillen/GithubCodeSearch
    #>
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
