. $PSScriptRoot\..\Src\QueryInvocation.ps1

Describe 'Invoke-GithubCodeSearch.Tests' {
    $searchText = 'break'
    $language = 'C#'
    $repository = 'ocp/ed209'
    $org = 'ocp'

    $basicAuthenticationToken = 'xyzzy'
    $queryString = 'q=(>^ ^)>'

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
                    [pscustomobject]@{ fragment = '// this breaks the build'}
                )
            }
        )
    }

    BeforeEach {
        Mock Get-GithubCodeSearchToken { $basicAuthenticationToken } -Verifiable

        Mock Get-GithubCodeSearchQueryString { $queryString } -Verifiable -ParameterFilter {
            $Text -eq $searchText -and `
            $Language -eq $language -and `
            $Repository -eq $repository -and `
            $Org -eq $org
        }

        Mock Invoke-RestMethod { $mockResponse } -Verifiable -ParameterFilter {
            $Uri -eq "https://api.github.com/search/code?$queryString" -and `
            $Headers.Authorization -eq "Basic $basicAuthenticationToken" -and `
            $Headers.Accept -eq 'application/vnd.github.v3.text-match+json'
        }
    }

    It 'builds up a the expected request' {
        $searchParameters = @{
            Text = $searchText
            Language = $language
            Repository = $repository
            Org = $org
        }

        Invoke-GithubCodeSearch @searchParameters

        Assert-VerifiableMock
    }

    it 'returns the URLs for matches' {
        $searchParameters = @{
            Text = $searchText
            Language = $language
            Repository = $repository
            Org = $org
        }

        $results = Invoke-GithubCodeSearch @searchParameters

        $results[0].URL | Should -Be 'http://result1.url'
        $results[1].URL | Should -Be 'http://result2.url'
    }

    it 'returns the matching text fragments' {
        $searchParameters = @{
            Text = $searchText
            Language = $language
            Repository = $repository
            Org = $org
        }

        $results = Invoke-GithubCodeSearch @searchParameters

        $results[0].Matches | Should -Be @('break;', 'break;')
        $results[1].Matches | Should -Be @('// this breaks the build')
    }
}
