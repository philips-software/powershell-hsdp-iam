function Test-ClientCmdlets {
    param($Application)

    $clientId = "test-$(((new-guid).Guid).Substring(0,15))"
    $globalReferenceId = (new-guid).Guid

    # CmdLet: Add-Client
    $addClient= Add-Client -Application $Application -ClientId $clientId -Password "Test@123" -Type "Public" -Name $clientId -Description "Device client1" `
                    -RedirectionURIs @("https://example.com/please/send/code_here") -ResponseTypes @("code id_token","id_token") `
                    -GlobalReferenceId $globalReferenceId -ConsentImplied

    # CmdLet: Get-Clients
    $getClient = Get-Clients -Id $addClient.Id
    if ($addClient.id -ne $getClient.id) {
        Write-Warning "Cross check of Add-Client and  Get-Clients failed"
        Write-Warning "$($addClient | ConvertTo-Json)"
        Write-Warning "$($getClient | ConvertTo-Json)"
    }

    # CmdLet: Set-Clients
    $getClient.description = "updated description"
    $setClient = Set-Client -Client $getClient
    $setGetClient = Get-Clients -Id $setClient.Id
    if ($setGetClient.description -ne $getClient.description) {
        Write-Warning "Cross check of Set-Client and Get-Clients failed"
        Write-Warning "$($setGetClient | ConvertTo-Json)"
        Write-Warning "$($getClient | ConvertTo-Json)"
    }

    # CmdLet: Set-ClientScopes
    Set-ClientScopes -Client $addClient -Scope @("scope_new") | Out-Null

    $getClientNewScope = Get-Clients -Id $addClient.Id
    if ($getClientNewScope.scopes[0] -ne "scope_new") {
        Write-Warning "Cross check of Set-ClientScopes and Get-Clients failed"
        Write-Warning "$($getClientNewScope | ConvertTo-Json)"
    }

    # HSDP issue that DELETE does not work
    # CmdLet: Remove-Client
    # $RemoveClient = Add-Client -Application $Application -ClientId "test-$(((new-guid).Guid).Substring(0,15))" -Password "Test@123" -Type "Public" -Name $clientId -Description "Device client2" `
    #     -RedirectionURIs @("https://example.com/please/send/code_here") -ResponseTypes @("code id_token","id_token") `
    #     -GlobalReferenceId $globalReferenceId -ConsentImplied

    # Remove-Client -Client $RemoveClient
    # if (Get-Clients -Id $RemoveClient .Id}) {}
    #     Write-Warning "Cross check of Remove-Client and Get-Clients failed"
    #     Write-Warning "$($getClientNewScope | ConvertTo-Json)"
    # }

    Write-Output $addClient
}