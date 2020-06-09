[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='needed to collect')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $IamUrl,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $IdmUrl,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $CredentialsUserName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $CredentialsPassword,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $AppCredentialsUserName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $AppCredentialsPassword,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $ClientCredentialsUserName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $ClientCredentialsPassword,
    [String[]]
    $Scopes = @("profile","email","read_write")
)

Import-Module -Name .\src\hsdp-iam -Force

$InformationPreference = "continue"
$ErrorActionPreference = "stop"

$p = @{
    Prompt = $false;
    CredentialsUserName = $CredentialsUserName;
    CredentialsPassword = $CredentialsPassword;
    ClientCredentialsUserName = $ClientCredentialsUserName;
    ClientCredentialsPassword = $ClientCredentialsPassword;
    Scopes = $Scopes;
    AppCredentialsUserName = $AppCredentialsUserName;
    AppCredentialsPassword = $AppCredentialsPassword;
    IamUrl = $IamUrl;
    IdmUrl = $IdmUrl;
}

$config = New-Config @p
Set-Config $config

$orgs = Get-Orgs -MyOrgOnly
if (-not $orgs) {
    throw "Sanity test of get-orgs failed"
}