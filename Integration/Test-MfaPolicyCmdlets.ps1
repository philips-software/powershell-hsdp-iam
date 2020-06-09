function Test-MfaPolicyCmdlets {
    param($Org)

    # CmdLet: Add-MFAPolicy
    $policy = Add-MFAPolicy -Org $Org -Name "mypolicy01" -Type "SOFT_OTP" -Description "Policy for $($Org.Name)"

    # CmdLet; Get-MFAPolicy
    $getPolicy= Get-MFAPolicy -Id $policy.Id
    if ($policy.Name -ne $getPolicy.Name) {
        Write-Warning "Cross check of Add-MFAPolicy and Get-MFAPolicy failed"
        Write-Warning "$($policy | ConvertTo-Json)"
        Write-Warning "$($getPolicy | ConvertTo-Json)"
    }

    # CmdLet: Set-MFAPolicy
    $getPolicy.description = "updated mfa policy description"
    $updatedPolicy = Set-MFAPolicy $getPolicy

    # CmdLet: Get-MFAPolicy
    $getPolicy2 = Get-MFAPolicy -Id $updatedPolicy.Id
    if ($updatedPolicy.description -ne $getPolicy2.description) {
        Write-Warning "Cross check of Set-MFAPolicy and Get-MFAPolicy failed"
        Write-Warning "$($updatedPolicy | ConvertTo-Json)"
        Write-Warning "$($getPolicy2 | ConvertTo-Json)"
    }

    # CmdLet: Remove-MFAPolicy
    Remove-MFAPolicy -Policy $policy | Out-Null
}
