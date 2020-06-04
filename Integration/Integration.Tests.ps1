<#
    .SYNOPSIS
    Integration tests for powershell module

    .DESCRIPTION
    This is the main entry point to execute all integration tests for the module.

    .INPUTS
    The configuration parameters for admin access to the IAM tenant
#>
param($IamUrl,$IdmUrl,$CredentialsUserName,$CredentialsPassword,$ClientCredentialsUserName,$ClientCredentialsPassword,$AppCredentialsUserName,$AppCredentialsPassword,$OAuth2CredentialsUserName,$OAuth2CredentialsPassword)

Import-Module ..\src\hsdp-iam -Force

. "$PSScriptRoot\Test-ApplicationCmdlets.ps1"
. "$PSScriptRoot\Test-AppService.ps1"
. "$PSScriptRoot\Test-CleanUpObjects.ps1"
. "$PSScriptRoot\Test-GroupCmdLets.ps1"
. "$PSScriptRoot\Test-MFAPolicyCmdLets.ps1"
. "$PSScriptRoot\Test-OAuthCmdLets.ps1"
. "$PSScriptRoot\Test-OrgCmdLets.ps1"
. "$PSScriptRoot\Test-PropositionCmdLets.ps1"
. "$PSScriptRoot\Test-RoleCmdLets.ps1"
. "$PSScriptRoot\Test-UserCmdLets.ps1"
. "$PSScriptRoot\Test-UnCoveredCmdLets.ps1"

function Test-Integration {
    param([HashTable]$config)

    # Configure the library
    Set-Config (New-Config @config)

    Test-OAuthCmdLets

    $rootOrgId = "e5550a19-b6d9-4a9b-ac3c-10ba817776d4"
    $Org = Test-OrgCmdlets -RootOrgId $rootOrgId
    Write-Debug ($Org | ConvertTo-Json)

    $User = Test-UserCmdlets -Org $Org
    Write-Debug ($User | ConvertTo-Json)

    $Proposition = Test-PropositionCmdlets -Org $Org
    Write-Debug ($Proposition | ConvertTo-Json)

    $Application = Test-ApplicationCmdlets -Proposition $Proposition
    Write-Debug ($Application | ConvertTo-Json)

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