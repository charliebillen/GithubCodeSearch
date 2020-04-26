. $PSScriptRoot\..\Src\TokenManagement.ps1

Describe 'Get-GithubCodeSearchToken' {
    $expectedToken = 'xyzzy'

    BeforeEach {
        Mock Get-Content { $expectedToken } -ParameterFilter { $Path -eq $GithubCodeSearchTokenConfig.TokenPath }
    }

    It 'returns the stored token' {
        Get-GithubCodeSearchToken | Should -Be $expectedToken
    }
}
