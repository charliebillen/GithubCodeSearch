@(
    'PSScriptAnalyzer'
    'Pester'
    'psake'
    'ConvertBase64Strings'
) | ForEach-Object {
    if (!(Get-Module -Name $_ -ListAvailable)) {
        Install-Module -Name $_ -Scope CurrentUser -Force
    }
}

Invoke-psake -buildFile $PSScriptRoot\PsakeTasks.ps1

exit (!$psake.build_success)
