function Test-UserCmdlets {
    param($Org)

    # CmdLet: Add-User
    $loginId = "test$((new-guid).Guid)"
    $email = "$($loginId)@mailinator.com"
    $newUser = Add-User -Org $Org -LoginId $loginId -Email $email -GivenName "tester" -FamilyName "tester"
    if ($null -eq $newUser) {
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
    $users = Get-Users -Org $Org
    if ($users -ne $newUser.Id) {
        Write-Warning "Cross check of New-User/Get-Users failed"
        Write-Warning "$($newUser | ConvertTo-Json)"
        Write-Warning "$($users | ConvertTo-Json)"
    }

    # CmdLet: Test-UserIds
    if (-not (Test-UserIds -Ids @($newUser.Id)) -eq $null) {
        Write-Warning "Cross check of New-User/Test-UserIds failed"
    }
    Write-Output $newUser
}
