Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Remove-Org.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-Org" {
    BeforeAll {
        $org = ([PSCustomObject]@{id = "1"})
        $rootPath = "/Organizations​"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            Remove-Org -Org $org
            Should -Invoke Invoke-ApiRequest -ParameterFilter {            
                ($Path -eq "/authorize/scim/v2/Organizations/$($org.id)") `
                    -and ($Method -eq "Delete") `
                    -and ($Version -eq "2") `
                    -and ($AdditionalHeaders["If-Method"] -eq "DELETE") `
                    -and ((Compare-Object $ValidStatusCodes @(202)) -eq $null)
            }
        }
    }
    Context "param" {       
        It "accepts value from pipeline " {
            $org | Remove-Org
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            {Remove-Org -Org $null } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
