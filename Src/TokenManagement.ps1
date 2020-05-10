#Requires -Module ConvertBase64Strings

$GithubCodeSearchTokenConfig = [pscustomobject]@{
    TokenPath = "$HOME\.githubcodesearch_token"
}

function Set-GithubCodeSearchToken {
    <#
    .SYNOPSIS
    Stores the specified GitHub username and password/access token.

    .DESCRIPTION
    Combines and Base64 encodes the provided username and token ready to use
    as HTTP Basic Authentication values when calling the GitHub search API.

    The value is stored in the file $HOME\.githubcodesearch_token.

    .PARAMETER Username
    The GitHub username to use when calling the API.

    .PARAMETER Token
    The GitHub password/access token to use when calling the API.

    .EXAMPLE
    Set-GithubCodeSearchToken -Username my_github_username -Token my_github_token

    .LINK
    https://github.com/charliebillen/GithubCodeSearch
    #>
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

function Get-GithubCodeSearchToken {    <#
    .SYNOPSIS
    Retrieves the Base64-encoded stored GitHub username and password/access token.

    .DESCRIPTION
    Reads and returns the contents of $HOME\.githubcodesearch_token

    .LINK
    https://github.com/charliebillen/GithubCodeSearch
    #>
    Get-Content -Path $GithubCodeSearchTokenConfig.TokenPath
}
