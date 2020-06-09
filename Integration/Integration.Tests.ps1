<#
    .SYNOPSIS
    Integration tests for powershell module

    .DESCRIPTION
    This is the main entry point to execute all integration tests for the module.

    .INPUTS
    The configuration parameters for admin access to the IAM tenant
#>
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

$PSScriptRoot
(Get-Location).Path

Import-Module -Name ./src/hsdp-iam -Force


. "$PSScriptRoot/Test-ApplicationCmdlets.ps1"
. "$PSScriptRoot/Test-AppService.ps1"
. "$PSScriptRoot/Test-CleanUpObjects.ps1"
. "$PSScriptRoot/Test-ClientCmdLets.ps1"
. "$PSScriptRoot/Test-GroupCmdLets.ps1"
. "$PSScriptRoot/Test-MFAPolicyCmdLets.ps1"
. "$PSScriptRoot/Test-OAuthCmdLets.ps1"
. "$PSScriptRoot/Test-OrgCmdLets.ps1"
. "$PSScriptRoot/Test-PropositionCmdLets.ps1"
. "$PSScriptRoot/Test-RoleCmdLets.ps1"
. "$PSScriptRoot/Test-UserCmdLets.ps1"
. "$PSScriptRoot/Test-UnCoveredCmdLets.ps1"

function Test-Integration {
    param([HashTable]$config)

    # Configure the library
    Set-Config (New-Config @config)

    Test-OAuthCmdLets

    $rootOrgId = "6618b09c-1c09-4887-a4d1-d8a4b285313c"
    $Org = Test-OrgCmdlets -RootOrgId $rootOrgId
    Write-Debug ($Org | ConvertTo-Json)

    $User = Test-UserCmdlets -Org $Org
    Write-Debug ($User | ConvertTo-Json)

    $Proposition = Test-PropositionCmdlets -Org $Org
    Write-Debug ($Proposition | ConvertTo-Json)

    $Application = Test-ApplicationCmdlets -Proposition $Proposition
    Write-Debug ($Application | ConvertTo-Json)

    $Client = Test-ClientCmdlets -Application $Application
    Write-Debug ($Client | ConvertTo-Json)

    $AppService = Test-AppService -Application $Application
    Write-Debug ($AppService | ConvertTo-Json)

    Test-MFAPolicyCmdLets -Org $Org

    $Group = Test-GroupCmdlets -Org $Org -User $User -AppService $AppService
    Write-Debug ($Group | ConvertTo-Json)

    Test-CleanUpObjects -Org $Org -User $User -Group $Group -AppService $AppService
}

# Output warning for cmdlets not specifically mentioned a comment for coverage
Test-UnCoveredCmdLets

Test-Integration -Config @{
    Prompt = $false;
    IamUrl = $IamUrl;
    IdmUrl = $IdmUrl;
    CredentialsUserName = $CredentialsUserName;
    CredentialsPassword = $CredentialsPassword;
    AppCredentialsUserName = $AppCredentialsUserName;
    AppCredentialsPassword = $AppCredentialsPassword;
    ClientCredentialsUserName = $ClientCredentialsUserName;
    ClientCredentialsPassword = $ClientCredentialsPassword;
    Scopes = $Scopes;
}