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

Import-Module -Name ./hsdp-iam/hsdp-iam -Force

. "$PSScriptRoot/Test-ApplicationCmdlets.ps1"
. "$PSScriptRoot/Test-AppServiceCmdlets.ps1"
. "$PSScriptRoot/Test-CleanUpObjects.ps1"
. "$PSScriptRoot/Test-ClientCmdlets.ps1"
. "$PSScriptRoot/Test-DeviceCmdlets.ps1"
. "$PSScriptRoot/Test-GroupCmdlets.ps1"
. "$PSScriptRoot/Test-MfaPolicyCmdlets.ps1"
. "$PSScriptRoot/Test-OAuthCmdlets.ps1"
. "$PSScriptRoot/Test-OrgCmdlets.ps1"
. "$PSScriptRoot/Test-PasswordPolicyCmdlets.ps1"
. "$PSScriptRoot/Test-PropositionCmdlets.ps1"
. "$PSScriptRoot/Test-RoleCmdlets.ps1"
. "$PSScriptRoot/Test-UserCmdlets.ps1"
. "$PSScriptRoot/Test-UnCoveredCmdlets.ps1"

function Test-Integration {
    param([HashTable]$config)

    Write-Progress -Activity "Integration Tests" -PercentComplete 0

    # Configure the library
    Set-Config (New-Config @config)

    Write-Progress -Activity "Integration Tests" -PercentComplete 5
    Test-OAuthCmdLets

    Write-Progress -Activity "Integration Tests" -PercentComplete 10
    $rootOrgId = "6618b09c-1c09-4887-a4d1-d8a4b285313c"
    $Org = Test-OrgCmdlets -RootOrgId $rootOrgId
    Write-Debug ($Org | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 15
    $PasswordPolicyWithKBA = Test-PasswordPolicyCmdlets -Org $org
    Write-Debug ($PasswordPolicyWithKBA | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 20
    $User = Test-UserCmdlets -Org $Org -PasswordPolicy $PasswordPolicyWithKBA
    Write-Debug ($User | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 30
    $Proposition = Test-PropositionCmdlets -Org $Org
    Write-Debug ($Proposition | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 40
    $Application = Test-ApplicationCmdlets -Proposition $Proposition
    Write-Debug ($Application | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 50
    $Device = Test-DeviceCmdlets -Org $Org -Application $Application
    Write-Debug ($Device | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 60
    $Client = Test-ClientCmdlets -Application $Application
    Write-Debug ($Client | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 70
    $AppService = Test-AppServiceCmdlets -Application $Application
    Write-Debug ($AppService | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 75
    Test-MfaPolicyCmdLets -Org $Org

    Write-Progress -Activity "Integration Tests" -PercentComplete 80
    $Group = Test-GroupCmdlets -Org $Org -User $User -AppService $AppService
    Write-Debug ($Group | ConvertTo-Json)

    Write-Progress -Activity "Integration Tests" -PercentComplete 90
    Test-CleanUpObjects -Org $Org -User $User -Group $Group -AppService $AppService

    Write-Progress -Activity "Integration Tests" -PercentComplete 100
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