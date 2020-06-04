function Test-RoleCmdLets {
    param($Org, $Group, $User)

    $roleName = "$(((new-guid).Guid).Substring(0,20))"
    # CmdLet: Add-Role
    $newRole = Add-Role -Org $Org -Name $roleName -Description "role for org $($Org.Id)"

    # CmdLet: Get-Role
    $getRole = Get-Role -Id $newRole.Id
    if ($newRole.Id -ne $getRole.Id) {
        Write-Warning "Cross check of Add-Role and Get-Role failed"
        Write-Warning "$($newRole | ConvertTo-Json)"
        Write-Warning "$($getRole | ConvertTo-Json)"
    }

    # CmdLet: Get-Roles
    $getRoles = Get-Roles -Name $roleName | Select-Object -First 1
    if ($getRoles.Id -ne  $getRole.Id) {
        Write-Warning "Cross check of Add-Role and Get-Roles failed"
        Write-Warning "$($getRoles | ConvertTo-Json)"
        Write-Warning "$($getRole | ConvertTo-Json)"
    }

    # CmdLet: Set-GroupRole
    Set-GroupRole -Group $Group -Role $newRole | Out-Null

    $rolesForGroup = Get-Roles -Group $group
    if ($rolesForGroup.Id -ne $newRole.Id) {
        Write-Warning "Cross check of Set-GroupRole and Get-Roles failed"
        Write-Warning "$($rolesForGroup | ConvertTo-Json)"
        Write-Warning "$($newRole | ConvertTo-Json)"
    }

    # CmdLet: Clear-GroupRole
    Clear-GroupRole -Group $Group -Role $newRole | Out-Null
    $rolesForGroup = Get-Roles -Group $group
    if ($null -ne $rolesForGroup) {
        Write-Warning "Cross check of Clear-GroupRole and Get-Roles failed"
        Write-Warning "$($rolesForGroup | ConvertTo-Json)"
        Write-Warning "$($newRole | ConvertTo-Json)"
    }

    # CmdLet: Set-GroupRole
    Set-GroupRole -Group $Group -Role $newRole | Out-Null

    # CmdLet: Set-GroupMember
    Set-GroupMember -Group $Group -User $User

    # CmdLet: Add-Permissions
    $addPermission = Add-Permissions -Role $Role @("PERMISSION_NAME_ADD")

    # CmdLet: Get-Permissions
    $getPermission = Get-Permissions -Role $Role | Select-Object -First 1
    if ($addPermission.Id -ne  $getPermission.Id) {
        Write-Warning "Cross check of Add-Permissions and Get-Permissions failed"
        Write-Warning "$($addPermission | ConvertTo-Json)"
        Write-Warning "$($getPermission | ConvertTo-Json)"
    }

    # CmdLet: Remove-Permissions
    Add-Permissions -Role $Role @("PERMISSION_NAME_REMOVE") | Out-Null
    Remove-Permissions -Role $Role @("PERMISSION_NAME_REMOVE") | Out-Null
    $checkRemoved = @(Get-Permissions -Role $Role)
    if ($checkRemoved.Length -eq 0) {
        Write-Warning "Cross check of Remove-Permissions and Get-Permissions failed"
        Write-Warning "$($checkRemoved | ConvertTo-Json)"
    }
}