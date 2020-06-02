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

Set-Config (New-Config @p)

$rootOrgId = "e5550a19-b6d9-4a9b-ac3c-10ba817776d4"

# Testing Org cmdlets.
$rootOrg = Get-Org -id $rootOrgId

if ($rootOrg -eq $null) {
    Write-Error "Root org $($rootOrgId) not found"
}

# CmdLet: Add-Org
$orgName =  "test-$((new-guid).Guid)"
$newOrg = Add-Org -ParentOrg $rootOrg -Name $orgName -Description "Integration testing org"
if ($newOrg -eq $null) {
    Write-Warning "new org was not created"
}

$getOrg = Get-Orgs -Name $orgName | Select -First 1
if ($getOrg.Id -ne $newOrg.Id) {
    Write-Warning "Cross check of Add-Org/Get-Orgs failed"
    Write-Warning "$($newOrg | ConvertTo-Json)"
    Write-Warning "$($getOrg | ConvertTo-Json)"
}

# CmdLet: Set-Org
$newOrg.description = "updated itegration testing org"
$updatedOrg = Set-Org $newOrg
$getOrg2 = Get-Orgs -Name $orgName | Select -First 1
if ($getOrg2.description -ne $newOrg.description) {
    Write-Warning "Cross check of Set-Org/Get-Orgs failed"
    Write-Warning "$($newOrg | ConvertTo-Json)"
    Write-Warning "$($getOrg2 | ConvertTo-Json)"
}

# CmdLet: Test-OrgIds
if ($null -ne (Test-OrgIds -Ids @($newOrg.Id))) {
    Write-Warning "Test-OrgIds did not find org $($newOrg.Id)"
    Write-Warning "$($newOrg | ConvertTo-Json)"
}

# CmdLet: Add-MFAPolicy
$policy = Add-MFAPolicy -Org $newOrg -Name "mypolicy01" -Type "SOFT_OTP" -Description "Policy for $($newOrg.Name)"

$getPolicy= Get-MFAPolicy -Id $policy.Id
if ($policy.Name -ne $getPolicy.Name) {
    Write-Warning "Cross check of Add-MFAPolicy and Get-MFAPolicy failed"
    Write-Warning "$($policy | ConvertTo-Json)"
    Write-Warning "$($getPolicy | ConvertTo-Json)"
}

# CmdLet: Set-MFAPolicy
$getPolicy.description = "updated mfa policy description"
$updatedPolicy = Set-MFAPolicy $getPolicy

$getPolicy2 = Get-MFAPolicy -Id $updatedPolicy.Id
if ($updatedPolicy.description -ne $getPolicy2.description) {
    Write-Warning "Cross check of Set-MFAPolicy and Get-MFAPolicy failed"
    Write-Warning "$($updatedPolicy | ConvertTo-Json)"
    Write-Warning "$($getPolicy2 | ConvertTo-Json)"
}

# CmdLet: Remove-MFAPolicy
Remove-MFAPolicy -Policy $policy | Out-Null

# CmdLet: Add-User

$user = "test$((new-guid).Guid)"
$email = "$($user)@mailinator.com"
$newUser = Add-User -Org $newOrg -LoginId $user -Email $email -GivenName "tester" -FamilyName "tester"
if ($newUser -eq $null) {
    Write-Warning "new user not created"
}

# CmdLet: Get-User
$getUser = Get-User -Id $newUser.Id

if ($newUser.loginId -ne $getUser.loginId) {
    Write-Warning "Cross check of New-User/Get-User failed"
    Write-Warning "$($newUser | ConvertTo-Json)"
    Write-Warning "$($getUser | ConvertTo-Json)"
}

# CmdLet: Get-Users
$users = Get-Users -Org $newOrg
if ($users -ne $newUser.Id) {
    Write-Warning "Cross check of New-User/Get-Users failed"
    Write-Warning "$($newUser | ConvertTo-Json)"
    Write-Warning "$($users | ConvertTo-Json)"
}

# CmdLet: Test-UserIds
if (-not (Test-UserIds -Ids @($newUser.Id)) -eq $null) {
    Write-Warning "Cross check of New-User/Test-UserIds failed"
}

# CmdLet: Add-Group
$groupName = "test$((new-guid).Guid)"
$addGroup = Add-Group -Org $newOrg -Name $groupName
if ($addGroup -eq $null) {
    Write-Warning "new group not created"
}

# CmdLet: Set-GroupIdentity
Set-GroupMember -Group $addGroup -User $newUser | Out-Null
$usersInGroup = Get-Users -Org $newOrg -Group $addGroup
if ($usersInGroup[0] -eq $newUser.Id) {
    Write-Warning "Cross check of Set-GroupIdentity/Get-Users failed"
    Write-Warning ($usersInGroup | ConvertTo-Json -Depth 20)
}

# CmdLet: Remove-GroupIdentity
Remove-GroupMember -Group $addGroup -User $newUser | Out-Null
if (-not (Get-Users -Org $newOrg -Group $addGroup) -eq $null) {
    Write-Warning "Cross check of Remove-GroupIdentity/Get-Users failed"
}

# CmdLet: Remove-User
Remove-User $newUser | Out-Null
if (-not (Get-Users -Org $newOrg) -eq $null) {
    Write-Warning "Remove-User should not return any users"
}

# CmdLet: Remove-Org
Remove-Org -Org $newOrg -Force

# CmdLet: Get-OrgRemoveStatus
Get-OrgRemoveStatus $newOrg | Out-Null