. $PSScriptRoot\..\Src\TokenManagement.ps1

Describe 'Set-GithubCodeSearchToken' {
    $base64Token = 'qwop=='
    $username = 'github_user'
    $token = 'github_personal_token'

    BeforeEach {
        $GithubCodeSearchTokenConfig.TokenPath = 'TestDrive:\token'

        Mock ConvertTo-Base64 { $base64Token } -ParameterFilter { $String -eq '{0}:{1}' -f $username, $token }

        Mock Set-Content {} -Verifiable -ParameterFilter {
            $Value -eq $base64Token -and `
            $Path -eq $GithubCodeSearchTokenConfig.TokenPath
        }
    }

    It 'returns the stored token' {
        Set-GithubCodeSearchToken -Username $username -Token $token -Confirm:$false

        Assert-VerifiableMock
    }
}
