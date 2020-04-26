. $PSScriptRoot\..\Src\QueryInvocation.ps1

Describe 'Get-GithubCodeSearchQueryString' {
    It 'returns the query text' {
        Get-GithubCodeSearchQueryString -Text 'goto' | Should -Be 'q=goto'
    }

    It 'includes the org if specified' {
        Get-GithubCodeSearchQueryString -Text 'goto' -Org 'ocp' | Should -Be 'q=goto+org:ocp'
    }

    It 'includes the repository if specified' {
        Get-GithubCodeSearchQueryString -Text 'goto' -Repository 'ocp/ed209' | Should -Be 'q=goto+repo:ocp/ed209'
    }

    It 'includes the language if specified' {
        Get-GithubCodeSearchQueryString -Text 'goto' -Language 'binary' | Should -Be 'q=goto+language:binary'
    }

    It 'URI-escapes the language' {
        Get-GithubCodeSearchQueryString -Text 'goto' -Language 'binary#' | Should -Be 'q=goto+language:binary%23'
    }
}
