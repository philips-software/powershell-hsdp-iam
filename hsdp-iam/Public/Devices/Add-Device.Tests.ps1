Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-Device.ps1"
    . "$PSScriptRoot\Get-Devices.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Device" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Device"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $appId = "42b5a081-55cb-41eb-bc03-e077eb85f516"
        $deviceId = "0ab7aace-8c16-4606-8f1c-1c1bb183d3dd"
        $orgId = "27ed8a6c-577f-4d1f-b0ab-22a6a95666e9"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $loginId = "DeviceloginId"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $externalId = "23423"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $password = "device1234"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $globalReferenceId = "5b92199e-9a24-4dfd-8e8b-8050308228b7"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $app = @{ Id = $appId }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = @{ Id = $orgId }
        $loginId = "DeviceloginId"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $type = "AIRFRYER"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $registrationDate = "2016-02-29T15:42:03.123Z"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $debugUntil = "2015-09-17T15:42:03.123Z"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $text = "Mobile Application Device"
    $response = (@{
            location = @("http://localhost/device/$($deviceId)")
        }) | ConvertTo-Json
        Mock Invoke-ApiRequest { $response }
        Mock Get-Devices
    }
    Context "api" {
        It "invoke request" {
            $ExpectedBody = @{
                organizationId = $orgId;
                applicationId = $appId;
                loginId = $loginId;
                deviceExtId = @{
                  system = "urn:philips-healthsuite.com";
                  value = $externalId;
                  type = @{
                    code = "ID";
                    text = "Device Identification";
                  }
                }
                password=$password;
                globalReferenceId = $globalReferenceId;
                forTest=$false;
                isActive = $true;
            }
            Add-Device -Org $org -App $app -LoginId $loginId -ExternalId $externalId `
                -Password $password -GlobalReferenceId $globalReferenceId
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $ReturnResponseHeader -eq $true -and
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null) -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
            Should -Invoke Get-Devices -ParameterFilter { $Id -eq $deviceId }
        }
        It "calls with all parameters" {
            $ExpectedBody = @{
                organizationId = $orgId;
                applicationId = $appId;
                loginId = $loginId ;
                deviceExtId = @{
                  system = "urn:philips-healthsuite.com";
                  value = $externalId;
                  type = @{
                    code = "ID";
                    text = "Device Identification";
                  }
                }
                password=$password;
                globalReferenceId = $globalReferenceId;
                type=$type;
                registrationDate=$registrationDate;
                forTest=$false;
                isActive = $false;
                debugUntil = $debugUntil;
                text = $text;
            }

            Add-Device -Org $org -App $app -LoginId $loginId -ExternalId $externalId `
                -Password $password -GlobalReferenceId $globalReferenceId `
                -Type $type -RegistrationDate $registrationDate -ForTest $false `
                -Active $false -DebugUntil $debugUntil `
                -Text $text

            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($ExpectedBody | ConvertTo-Json)
                Write-Debug ($Body | ConvertTo-Json)
                $true
                #$true ($null -eq ($ExpectedBody, $Body | Test-Equality))
            }
        }

    }
    Context "param" {
        It "accepts value from pipeline" {
            $Org | Add-Device -App $app -LoginId $loginId -ExternalId $externalId -Password $password -GlobalReferenceId $globalReferenceId
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures Org is not null" {
            { Add-Device -Org $null -App $app -LoginId $loginId -ExternalId $externalId -Password $password -GlobalReferenceId $globalReferenceId } | Should -Throw "*'Org'. The argument is null*"
        }
        It "ensures App is not null" {
            { Add-Device -Org $org -App $null -LoginId $loginId -ExternalId $externalId -Password $password -GlobalReferenceId $globalReferenceId } | Should -Throw "*'App'. The argument is null*"
        }
        It "accepts value by position" {
            Add-Device $org $app $loginId $externalId `
            $password $globalReferenceId `
            $type $registrationDate $false `
            $false $debugUntil `
            $text
            Should -Invoke Invoke-ApiRequest
        }

    }
}