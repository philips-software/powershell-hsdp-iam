Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-AppService.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-AppService" {
    BeforeAll {
        $PrivateKey = "xxxxx"
        $response = @{ privateKey = $PrivateKey }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Application = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Name = "app1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $PrivateKeyPath = "app1.key"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Validity = 12
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Description = "desc1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Service"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            "applicationId"     = $Application.id;
            "name"              = $Name;
            "description"       = $Description;
            "validity"          = $Validity;
        }
        Mock Invoke-ApiRequest { $response }
        Mock Set-Content
    }
    Context "api" {
        It "invokes request" {
            $result = Add-AppService -Application $Application -Name $Name -PrivateKeyPath $PrivateKeyPath -Validity $Validity -Description $Description
            $result | Should -Be $response
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ($ExpectedBody, $Body | Test-Equality) -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null)
            }
            Should -Invoke Set-Content -ParameterFilter {
                $Path -eq $PrivateKeyPath -and $Value -eq $response.privateKey
            }
        }
        It "adds newlines to private key" {
            $PrivateKey = "-----BEGIN RSA PRIVATE KEY-----xxxxx-----END RSA PRIVATE KEY-----"
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $response = @{ privateKey = $PrivateKey }
            Add-AppService -Application $Application -Name $Name -PrivateKeyPath $PrivateKeyPath -Validity $Validity -Description $Description
            Should -Invoke Set-Content -ParameterFilter {
                ($Value | ConvertTo-Json) -eq "`"-----BEGIN RSA PRIVATE KEY-----\nxxxxx\n-----END RSA PRIVATE KEY----------BEGIN RSA PRIVATE KEY-----\nxxxxx-----END RSA PRIVATE KEY-----\n`""
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $Application | Add-AppService -Name $Name -PrivateKeyPath $PrivateKeyPath -Validity $Validity -Description $Description
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Application not null" {
            { Add-AppService -Application $null -Name $Name -PrivateKeyPath $PrivateKeyPath -Validity $Validity -Description $Description } | Should -Throw "*'Application'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            { Add-AppService -Application $Application -Name $null -PrivateKeyPath $PrivateKeyPath -Validity $Validity -Description $Description } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            { Add-AppService -Application $Application -Name "" -PrivateKeyPath $PrivateKeyPath -Validity $Validity -Description $Description } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -PrivateKeyPath not null" {
            { Add-AppService -Application $Application -Name $Name -PrivateKeyPath $null -Validity $Validity -Description $Description } | Should -Throw "*'PrivateKeyPath'. The argument is null or empty*"
        }
        It "ensures -PrivateKeyPath not empty" {
            { Add-AppService -Application $Application -Name $Name -PrivateKeyPath "" -Validity $Validity -Description $Description } | Should -Throw "*'PrivateKeyPath'. The argument is null or empty*"
        }
        It "supports by position" {
            Add-AppService $Application $Name $PrivateKeyPath $Validity $Description
            Should -Invoke Invoke-ApiRequest -ParameterFilter { ($ExpectedBody, $Body | Test-Equality) }
        }
    }
}