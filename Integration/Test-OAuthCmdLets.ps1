function Test-OAuthCmdlets {
    param()
    # CmdLet: Get-Introspect
    $introspect = Get-Introspect
    if ($introspect.username -ne $config.CredentialsUserName) {
        Write-Warning "Get-Introspect did not match current user"
    }

    # CmdLet: Get-UserInfo
    $UserInfo = Get-UserInfo
    if ($UserInfo.email -ne $config.CredentialsUserName) {
        Write-Warning "Get-UserInfo did not match current user"
        Write-Warning $UserInfo.email
        Write-Warning $config.CredentialsUserName
    }
}