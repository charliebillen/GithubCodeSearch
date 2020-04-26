#Requires -Module ConvertBase64Strings

$GithubCodeSearchTokenConfig = [pscustomobject]@{
    TokenPath = "$HOME\.githubcodesearch_token"
}

function Set-GithubCodeSearchToken {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [string]
        $Username,

        [Parameter(Mandatory)]
        [string]
        $Token
    )

    $base64Token = '{0}:{1}' -f $Username, $Token | ConvertTo-Base64

    if ($PSCmdlet.ShouldProcess($base64Token)) {
        Set-Content -Value $base64Token -Path $GithubCodeSearchTokenConfig.TokenPath -Force
    }
}

function Get-GithubCodeSearchToken {
    Get-Content -Path $GithubCodeSearchTokenConfig.TokenPath
}
