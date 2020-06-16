function Test-PasswordPolicyCmdlets {
    param($Org)

    # CmdLet: Add-PasswordPolicy
    $addPasswordPolicy = Add-PasswordPolicy -Org $Org -ChallengesEnabled -DefaultQuestions @("color") -MinQuestionCount 1 -MinAnswerCount 1 -MaxIncorrectAttempts 5
    if ($null -eq $addPasswordPolicy) {
        Write-Warning "Password policy not creatd"
    }

    # CmdLet: Get-PasswordPolicy
    $getPasswordPolicy = Get-PasswordPolicy -Id $addPasswordPolicy.Id

    if ($addPasswordPolicy.Id -ne $getPasswordPolicy.Id) {
        Write-Warning "Cross check of Add-PasswordPolicy/Get-PasswordPolicy failed"
        Write-Warning "$($addPasswordPolicy | ConvertTo-Json)"
        Write-Warning "$($getPasswordPolicy | ConvertTo-Json)"
    }

    # CmdLet: Get-PasswordPolicies
    $getPasswordPolicies = Get-PasswordPolicies -Org $org

    if ($getPasswordPolicies.Id -ne $getPasswordPolicy.Id) {
        Write-Warning "Cross check of Get-PasswordPolicies/Get-PasswordPolicy failed"
        Write-Warning "$($getPasswordPolicies | ConvertTo-Json)"
        Write-Warning "$($getPasswordPolicy | ConvertTo-Json)"
    }

    # CmdLet: Set-PasswordPolicy
    $getPasswordPolicy.historyCount = 2
    $setPasswordPolicy = Set-PasswordPolicy -Policy $getPasswordPolicy

    $getPasswordPolicy = Get-PasswordPolicy -Id $setPasswordPolicy.Id
    if ($setPasswordPolicy.Id -ne $getPasswordPolicy.Id) {
        Write-Warning "Cross check of Get-PasswordPolicy/Set-PasswordPolicies failed"
        Write-Warning "$($setPasswordPolicy | ConvertTo-Json)"
        Write-Warning "$($getPasswordPolicy | ConvertTo-Json)"
    }

    # CmdLet: Remove-PasswordPolicy
    Remove-PasswordPolicy -Policy $getPasswordPolicy -Force
    $getPasswordPolicies = Get-PasswordPolicies -Org $org

    if ($null -ne $getPasswordPolicies) {
        Write-Warning "Cross check of Remove-PasswordPolicy/Get-PasswordPolicies failed"
    }

    # create a policy and return it
    Write-Output (Add-PasswordPolicy -Org $Org -ChallengesEnabled -DefaultQuestions @("color") -MinQuestionCount 1 -MinAnswerCount 1 -MaxIncorrectAttempts 5)
}
