function Test-ApplicationCmdlets {
    param($Proposition)

    # CmdLet: Add-Application
    $addApplication = Add-Application -Proposition $Proposition -Name "$(((new-guid).Guid).Substring(0,20))" -GlobalReferenceId $((new-guid).Guid) -Description "test for prop $($Proposition.Id)"
    if ($null -eq $addApplication) {
        Write-Warning "new application not created"
    }

    # CmdLet: Get-Applications
    $getApplication = Get-Applications -Id $addApplication.Id
    if ($getApplication.Id -ne $addApplication.Id) {
        Write-Warning "Cross check of Add-Application and Get-Application failed"
        Write-Warning "$($addApplication | ConvertTo-Json)"
        Write-Warning "$($getApplication | ConvertTo-Json)"
    }
    Write-Output $addApplication
}