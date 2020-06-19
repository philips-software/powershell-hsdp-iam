function Test-AppServiceCmdlets {
    param($Application)

    $keyfile = "app1.key"
    if (Test-Path $keyfile) {
        Remove-Item $keyfile
    }

    # CmdLet: Add-AppService
    $addAppService = Add-AppService -Application $Application -Name "$(((new-guid).Guid).Substring(0,20))" -PrivateKeyPath $keyfile
    if ($null -eq $addAppService) {
        Write-Warning "new service not created"
    }

    # CmdLet: Get-AppService
    $getAppService = Get-AppService -Id $addAppService.Id
    if ($addAppService.Id -ne $getAppService.Id) {
        Write-Warning "Cross check of Add-AppService and Get-AppService failed"
        Write-Warning "$($newApplication | ConvertTo-Json)"
        Write-Warning "$($getApplication | ConvertTo-Json)"
    }

    # CmdLet: Set-AppServiceScope
    Set-AppServiceScope -AppService $addAppService -Action add -Scopes @('add-1','add-2') -DefaultScopes @('add-1','add-2')
    $getAppService = Get-AppService -Id $addAppService.Id
    if (-not $getAppService.scopes.Contains('add-1') -or -not $getAppService.scopes.Contains('add-2')) {
        Write-Warning "Set-AppServiceScope did not add scopes"
        Write-Warning "$($getAppService | ConvertTo-Json)"
    }
    Set-AppServiceScope -AppService $addAppService -Action remove -Scopes @('add-1') -DefaultScopes @('add-1')
    $getAppService = Get-AppService -Id $addAppService.Id
    if ($getAppService.scopes.Contains('add-1')) {
        Write-Warning "Set-AppServiceScope did not remove scopes"
        Write-Warning "$($getAppService | ConvertTo-Json)"
    }

    # CmdLet: New-HsdpJWT
    $jwt = New-HsdpJWT -Service $addAppService -KeyFile $keyfile
    if ($null -eq $jwt) {
        Write-Warning "New-HsdpJWT did not create new JWT"
    }

    # CmdLet: Get-TokenFromJWT
    $token = Get-TokenFromJWT -JWT $jwt
    if ($null -eq $token) {
        Write-Warning "Get-TokenFromJWT did not return token"
    }

    Write-Output $addAppService
}