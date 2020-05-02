. $PSScriptRoot\..\Src\QueryInvocation.ps1

Describe 'Invoke-GithubCodeSearch.Tests' {
    $searchParameters = @{
        Text = 'break'
        Language = 'C#'
        Repo = 'ocp/ed209'
        Org = 'ocp'
        PerPage = 10
        Page = 20
    }

    $basicAuthenticationToken = 'xyzzy'
    $queryString = 'q=(>^ ^)>?'

    $mockResponse = [pscustomobject]@{
        items = @(
            [pscustomobject]@{
                html_url = 'http://result1.url'
                text_matches = @(
                    [pscustomobject]@{ fragment = 'break;' }
                    [pscustomobject]@{ fragment = 'break;' }
                )
            }
            [pscustomobject]@{
                html_url = 'http://result2.url'
                text_matches = @(
                    [pscustomobject]@{ fragment = '// this breaks the build' }
                )
            }
        )
    }

    BeforeEach {
        Mock Get-GithubCodeSearchToken { $basicAuthenticationToken } -Verifiable

        Mock Get-GithubCodeSearchQueryString { $queryString } -Verifiable -ParameterFilter {
            $Text -eq $searchParameters.Text -and `
            $Language -eq $searchParameters.Language -and `
            $Repo -eq $searchParameters.Repo -and `
            $Org -eq $searchParameters.Org -and `
            $PerPage -eq $searchParameters.PerPage -and `
            $Page -eq $searchParameters.Page
        }

        Mock Invoke-RestMethod { $mockResponse } -Verifiable -ParameterFilter {
            $Uri -eq "https://api.github.com/search/code?$queryString" -and `
            $Headers.Authorization -eq "Basic $basicAuthenticationToken" -and `
            $Headers.Accept -eq 'application/vnd.github.v3.text-match+json'
        }
    }

    It 'builds up a the expected request' {
        Invoke-GithubCodeSearch @searchParameters

        Assert-VerifiableMock
    }

    it 'returns the URLs for matches' {
        $results = Invoke-GithubCodeSearch @searchParameters

        $results[0].URL | Should -Be 'http://result1.url'
        $results[1].URL | Should -Be 'http://result2.url'
    }

    it 'returns the matching text fragments' {
        $results = Invoke-GithubCodeSearch @searchParameters

        $results[0].Matches | Should -Be @('break;', 'break;')
        $results[1].Matches | Should -Be @('// this breaks the build')
    }
}
