Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-AppService.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-AppService" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Id = "1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Name = "app1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Application = @{Id="2"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = @{id="3"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $PrivateKeyPath = "app1.key"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Service"
        $resource = @{privateKey=""}
        $response = @{ entry = $resource }
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request for id" {
            $result = Get-AppService -Id $Id
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?_id=$($Id)&pageSize=99999" -and `
                    $Version -eq 1 -and `
                    (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $resource
        }
        It "invoke request for Name" {
            Get-AppService -Name $Name
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?name=$($Name)&pageSize=99999"
            }
        }
        It "invoke request for Application" {
            Get-AppService -Application $Application
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?applicationId=$($Application.id)&pageSize=99999"
            }
        }
        It "invoke request for Org" {
            Get-AppService -Org $Org
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($Org.id)&pageSize=99999"
            }
        }
        It "adds key content to request" {
            $content = "foo"
            Mock Get-Content {$content}
            $result = Get-AppService -Org $Org -PrivateKeyPath $PrivateKeyPath
            Should -Invoke Get-Content -ParameterFilter {
                [String]$Path -eq $PrivateKeyPath
            }
            $result.privateKey | Should -Be $content
        }


    }
    Context "param" {
        It "accepts value from pipeline" {
            $Id | Get-AppService
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Name is exclusive" {
            {  Get-AppService -Name $Name -Application $Application } | Should -Throw "*One or more parameters issued cannot be used together*"
            {  Get-AppService -Name $Name -Id $Id } | Should -Throw "*One or more parameters issued cannot be used together*"
        }
        It "ensures -Org is exclusive" {
            {  Get-AppService -Org $Org -Application $Application } | Should -Throw "*One or more parameters issued cannot be used together*"
            {  Get-AppService -Org $Org -Id $Id } | Should -Throw "*One or more parameters issued cannot be used together*"
        }
        It "ensures -Id is exclusive" {
            {  Get-AppService -Id $Id -Application $Application } | Should -Throw "*One or more parameters issued cannot be used together*"
            {  Get-AppService -Id $Id -Org $Org } | Should -Throw "*One or more parameters issued cannot be used together*"
        }
        It "ensures -Id is exclusive" {
            {  Get-AppService -Id $Id -Application $Application } | Should -Throw "*One or more parameters issued cannot be used together*"
            {  Get-AppService -Id $Id -Org $Org } | Should -Throw "*One or more parameters issued cannot be used together*"
        }
        It "ensures -PrivateKeyPath not null" {
            { Get-AppService -Id $Id -PrivateKeyPath $null } | Should -Throw "*'PrivateKeyPath'. The argument is null or empty*"
        }
        It "ensures -PrivateKeyPath not empty" {
            { Get-AppService -Id $Id -PrivateKeyPath "" } | Should -Throw "*'PrivateKeyPath'. The argument is null or empty*"
        }
    }
}