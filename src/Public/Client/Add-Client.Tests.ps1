Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-Client.ps1"
    . "$PSScriptRoot\Get-Clients.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Client" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Client"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Application = [PSObject]@{Id="1"}
        $addClientId = "b748c7de-b224-4599-bb0b-6fdca7141277"
        $response = @{ Location = @("http//localhost/$($addClientId)") } | ConvertTo-Json
        $Client = @{ Id = $addClientId }
        $ExpectedClientId = "testhsdpclient"
        $ExpectedPassword = "test@123"
        $ExpectedType = "Public"
        $ExpectedName = "TestClient"
        $ExpectedDescription = "Device client1"
        $ExpectedRedirectionURIs =  @("https://example.com/please/send/code_here")
        $ExpectedResponseType = @("code id_token","d_token")
        $ExpectedGlobalReferenceId = "46908508-bfd9-4fce-9188-454e9ec44f79"
        $ExpectedAccessTokenLifetime = 3600
        $ExpectedRefreshTokenLifetime = 5184000
        $ExpectedIdTokenLifetime = 604800
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            "clientId"= $ExpectedClientId;
            "password"= $ExpectedPassword;
            "type"= $ExpectedType;
            "name"= $ExpectedName;
            "description"= $ExpectedDescription;
            "redirectionURIs"= $ExpectedRedirectionURIs;
            "responseTypes"= $ExpectedResponseType;
            "applicationId"= $Application.Id;
            "globalReferenceId"= $ExpectedGlobalReferenceId;
            "consentImplied"= "True";
            "accessTokenLifetime"= $ExpectedAccessTokenLifetime;
            "refreshTokenLifetime"= $ExpectedRefreshTokenLifetime;
            "idTokenLifetime"= $ExpectedIdTokenLifetime;
        }
        Mock Invoke-ApiRequest { $response }
        Mock Get-Clients { $Client }
    }
    Context "api" {
        It "invoke request" {
            Add-Client -Application $Application -ClientId $ExpectedClientId -Password $ExpectedPassword -Type $ExpectedType -Name $ExpectedName -Description $ExpectedDescription `
                -RedirectionURIs $ExpectedRedirectionURIs -ResponseTypes $ExpectedResponseType `
                -GlobalReferenceId $ExpectedGlobalReferenceId -ConsentImplied -AccessTokenLifetime $ExpectedAccessTokenLifetime -RefreshTokenLifetime $ExpectedRefreshTokenLifetime `
                -IdTokenLifetime $ExpectedIdTokenLifetime
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($Body | ConvertTo-Json)
                Write-Debug ($ExpectedBody | ConvertTo-Json)
                $ReturnResponseHeader -eq $true -and
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null) -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
            Should -Invoke Get-Clients -ParameterFilter { $Id -eq $addClientId }
        }
    }
}