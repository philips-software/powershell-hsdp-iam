
function Test-GroupCmdlets {
    param($Org, $User, $AppService)

    # CmdLet: Add-Group
    $groupName = "$(((new-guid).Guid).Substring(0,20))"
    $addGroup = Add-Group -Org $Org -Name $groupName
    if ($null -eq $addGroup) {
        Write-Warning "new group not created"
    }

    # CmdLet: Test-GroupInOrgs
    $invalidOrgs = @(Test-G./loroupInOrgs -OrgIds @($Org.Id) -GroupName $groupName)
    if ($invalidOrgs.Count -gt 0) {
        Write-Warning "Test-GroupInOrgs should have not returned any orgs"
        Write-Warning ($invalidOrgs | ConvertTo-Json)
        Write-Warning ($Org | ConvertTo-Json)
        Write-Warning $groupName
    }

    # CmdLet: Get-Group
    $getGroup = Get-Group -Id $addGroup.Id
    if ($addGroup.id -ne $getGroup.id) {
        Write-Warning "Cross check of Add-Group and  Get-Group failed"
        Write-Warning "$($addGroup | ConvertTo-Json)"
        Write-Warning "$($getGroup | ConvertTo-Json)"
    }
    # CmdLet: Get-Groups
    $getGroups = Get-Groups -Org $Org -Name $groupName | Select-Object -First 1
    if ($addGroup.id -ne $getGroups.id) {
        Write-Warning "Cross check of Add-Groups and  Get-Groups failed"
        Write-Warning "$($addGroup | ConvertTo-Json)"
        Write-Warning "$($getGroups | ConvertTo-Json)"
    }
    # CmdLet: Set-GroupMember
    Set-GroupMember -Group $addGroup -User $User | Out-Null
    $usersInGroup = Get-Users -Org $Org -Group $addGroup | Select-Object -First 1
    if ($null -eq $usersInGroup -or $User.Id -ne $User.Id) {
        Write-Warning "Cross check of Set-GroupMember/Get-Users failed"
        Write-Warning ($usersInGroup | ConvertTo-Json -Depth 20)
    }
    # The Group but be retrieved to get the correct eTag in the version or Set-GroupIdentity will fail
    # The HSDP API for setting the group membership alters the object but does not return
    # the new eTag.
    $getGroup = Get-Group -Id $addGroup.Id

    # CmdLet: Set-GroupIdentity
    Set-GroupIdentity -Group $getGroup -Ids @($AppService.Id) -MemberType "SERVICE" | Out-Null
    $groupAssisngedIdentity = Get-Groups -Org $Org -MemberType "SERVICE" -MemberId $AppService.Id
    if ($groupAssisngedIdentity.id -ne $addGroup.id) {
        Write-Warning "Cross check of Set-GroupIdentity and  Get-Groups failed"
        Write-Warning "$($addGroup | ConvertTo-Json)"
        Write-Warning "$($groupAssisngedIdentity | ConvertTo-Json)"
    }

    # CmdLet: Remove-GroupIdentity
    Remove-GroupIdentity -Group $getGroup @($AppService.Id) -MemberType "SERVICE" | Out-Null

    Write-Output $addGroup
}