
function Test-CleanUpObjects {
    param($Org, $User, $Group, $AppService)

    # CmdLet: Remove-AppService
    if ($PSBoundParameters.ContainsKey('AppService')) {
        Remove-AppService -Service $AppService | Out-Null
        if (-not (Get-AppService -Id $AppService.Id) -eq $null) {
            Write-Warning "Cross check of Remove-AppService/Get-AppService failed"
        }
    }

    if ($PSBoundParameters.ContainsKey('Group')) {
        # CmdLet: Remove-GroupMember
        Remove-GroupMember -Group $Group -User $User | Out-Null
        if (-not (Get-UserIds -Org $Org -Group $Group) -eq $null) {
            Write-Warning "Cross check of Remove-GroupMember/Get-UserIds failed"
        }
    }

    if ($PSBoundParameters.ContainsKey('User')) {
        # CmdLet: Remove-User
        Remove-User $User | Out-Null
        if (-not (Get-UserIds -Org $Org) -eq $null) {
            Write-Warning "Remove-User should not return any users"
        }
    }

    if ($PSBoundParameters.ContainsKey('Org')) {
        # CmdLet: Remove-Org
        Remove-Org -Org $Org -Force

        # CmdLet: Get-OrgRemoveStatus
        $status = Get-OrgRemoveStatus $Org
        if ($status -ne "IN_PROGRESS") {
            Write-Warning "Get-OrgRemoveStatus should return 'IN PROGRESS' but returned '$($status)'"
        }
    }

}