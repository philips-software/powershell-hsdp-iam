
function Test-OrgCmdlets {
    param($RootOrgId)

    # Testing Org cmdlets.
    $rootOrg = Get-Org -id $RootOrgId

    if ($null -eq $rootOrg) {
        Write-Error "Root org $($RootOrgId) not found"
    }

    # CmdLet: Add-Org
    $orgName =  "test-$((new-guid).Guid)"
    $addOrg = Add-Org -ParentOrg $rootOrg -Name $orgName -Description "integration testing org"
    if ($null -eq $addOrg) {
        Write-Warning "new org was not created"
    }

    # CmdLet: Get-Orgs
    $getOrg = Get-Orgs -Name $orgName | Select-Object -First 1
    if ($getOrg.Id -ne $addOrg.Id) {
        Write-Warning "Cross check of Add-Org/Get-Orgs failed"
        Write-Warning "$($addOrg | ConvertTo-Json)"
        Write-Warning "$($getOrg | ConvertTo-Json)"
    }

    # CmdLet: Set-Org
    $addOrg.description = "integration testing org (updated)"
    Set-Org $addOrg | Out-Null
    $getOrg2 = Get-Orgs -Name $orgName | Select-Object -First 1
    if ($getOrg2.description -ne $addOrg.description) {
        Write-Warning "Cross check of Set-Org/Get-Orgs failed"
        Write-Warning "$($addOrg | ConvertTo-Json)"
        Write-Warning "$($getOrg2 | ConvertTo-Json)"
    }

    # CmdLet: Test-OrgIds
    if ($null -ne (Test-OrgIds -Ids @($addOrg.Id))) {
        Write-Warning "Test-OrgIds did not find org $($addOrg.Id)"
        Write-Warning "$($addOrg | ConvertTo-Json)"
    }
    Write-Output $addOrg
}