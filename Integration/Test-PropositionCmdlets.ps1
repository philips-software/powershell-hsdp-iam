function Test-PropositionCmdlets {
    param($Org)

    # CmdLet: Add-Proposition
    $newProposition = Add-Proposition -Org $Org -Name "$(((new-guid).Guid).Substring(0,20))" -GlobalReferenceId $((new-guid).Guid) -Description "test for org $($Org.Id)"
    if ($null -eq $newProposition) {
        Write-Warning "new proposition not created"
    }

    # CmdLet: Get-Propositions
    $getProp = Get-Propositions -Id $newProposition.Id
    if ($null -eq $getProp) {
        Write-Warning "Cross check of Add-Proposition and Get-Proposition failed"
        Write-Warning "$($newProposition | ConvertTo-Json)"
        Write-Warning "$($getProp | ConvertTo-Json)"
    }
    Write-Output $newProposition
}