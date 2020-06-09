function Test-UnCoveredCmdLets  {
    $allFiles = Get-ChildItem ./src/Public/*.ps1 -Recurse
    $notTestFiles = $allFiles | Where-Object { $_.name -notlike "*.Tests.ps1"}
    $cmdletsFiles  = $notTestFiles | Select-Object @{Name="name";Expression={$_.Name -replace ".ps1",""}} | Sort-Object name
    $TestFiles = Get-ChildItem ./Integration/Test-*.ps1
    $fileContents = $TestFiles | ForEach-Object { Get-Content $_.FullName }
    $unCoveredCmdLets = $cmdletsFiles | ForEach-Object {
        $matchComment = "# CmdLet: $($_.Name)"
        if ($null -eq ($fileContents | Select-String $matchComment)) { $_.Name }
    }
    $skipCover = @(
        "Wait-Action",
        "Get-ApiSignatureHeaders",
        "Get-ApplicationsByPage",
        "Get-PropositionsByPage",
        "Get-Config",
        "Get-Headers",
        "Get-UsersByPage",
        "Get-OrgsByPage",
        "Get-ClientsByPage",
        "Invoke-ApiRequest",
        "Invoke-GetRequest",
        "Invoke-Retry",
        "New-Config",
        "Read-Config",
        "Set-Config",
        "Set-FileConfig",
        "Get-Evaluate",
        "Import-UsersToOrgGroups","Set-UsersInGroup","Set-UsersToOrgGroups"
    )
    $thisFileShouldCover = (Compare-Object $unCoveredCmdLets $skipCover)
    if ($thisFileShouldCover) {
        Write-Warning "The files named ./Test-* does not a comment indicating the testing of the following cmdlets:"
        $thisFileShouldCover | ForEach-Object { Write-Warning $_.InputObject }
    }
}