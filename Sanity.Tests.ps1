[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='needed to collect')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
param($IamUrl,$IdmUrl,$CredentialsUserName,$CredentialsPassword,$ClientCredentialsUserName,$ClientCredentialsPassword,$AppCredentialsUserName,$AppCredentialsPassword,$OAuth2CredentialsUserName,$OAuth2CredentialsPassword)

Import-Module -Name ./src/hsdp-iam -Force

$InformationPreference = "continue"
$ErrorActionPreference = "stop"

$p = @{
    Prompt = $false;
    CredentialsUserName = $CredentialsUserName;
    CredentialsPassword = $CredentialsPassword;
    ClientCredentialsUserName = $ClientCredentialsUserName;
    ClientCredentialsPassword = $ClientCredentialsPassword;
    AppCredentialsUserName = $AppCredentialsUserName;
    AppCredentialsPassword = $AppCredentialsPassword;
    OAuth2CredentialsUserName = $OAuth2CredentialsUserName;
    OAuth2CredentialsPassword = $OAuth2CredentialsPassword;
    IamUrl = $IamUrl;
    IdmUrl = $IdmUrl;
}

$config = New-Config @p
Set-Config $config

$orgs = Get-Orgs
if (-not $orgs) {
    throw "Sanity test of get-orgs failed"
}