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