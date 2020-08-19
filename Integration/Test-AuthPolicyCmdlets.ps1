function Test-AuthPolicyCmdlets {
    param($Org)

    # CmdLet: Add-AuthPolicy
    $addAuthPolicy = Add-AuthPolicy -Org $Org -Name MyPolicy -PolicySetId "fcdc19b2-8722-4b83-8d5f-78621d7c44f3" -Resources @("https://*:*/service/practitioner*?*") `
        -Actions @{ POST=$true; GET=$true; DELETE=$false } -SubjectType "Permission" -Subjects @("PRACTITIONER.ANY") -Conditions @("openid", "mail", "read_only")

    # CmdLet: Get-AuthPolicy
    $getAuthPolicy = Get-AuthPolicy -Id $addAuthPolicy.Id
    if ($addAuthPolicy.id -ne $getAuthPolicy.id) {
        Write-Warning "Cross check of Add-AuthPolicy and Get-AuthPolicy failed"
        Write-Warning "$($addAuthPolicy | ConvertTo-Json -Depth 100)"
        Write-Warning "$($getAuthPolicy | ConvertTo-Json -Depth 100)"
    }

    # CmdLet: Get-AuthPolicies
    $getAuthPolicies = Get-AuthPolicies -Org $Org

    if ($getAuthPolicies[0].id -ne $addAuthPolicy.id) {
        Write-Warning "Cross check of Add-AuthPolicy and Get-AuthPolicies failed"
        Write-Warning "$($getAuthPolicies | ConvertTo-Json -Depth 100)"
        Write-Warning "$($addAuthPolicy | ConvertTo-Json -Depth 100)"
    }

    # CmdLet: Remove-AuthPolicy
    $removeResult = Remove-AuthPolicy -Policy $getAuthPolicy -Force

    if ($null -ne $removeResult) {
        Write-Warning "Remove-AuthPolicy failed with $($RemoveResult | ConvertTo-Json -Depth 100)"
    }
}
