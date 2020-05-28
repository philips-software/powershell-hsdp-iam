$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-Org.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Remove-Org" {
    $org = ([PSCustomObject]@{id = "1"})
    Mock Invoke-ApiRequest
    $rootPath = "/Organizations​"
    Context "remove an org" {
        Remove-Org -Org $org
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {            
            ($Path -eq "/authorize/scim/v2/Organizations/$($org.id)") `
                -and ($Method -eq "Delete") `
                -and ($Version -eq "2") `
                -and ($AdditionalHeaders["If-Method"] -eq "DELETE") `
                -and ((Compare-Object $ValidStatusCodes @(202)) -eq $null)
        }
    }
    Context "parameters" {       
        It "support Org from pipeline " {
            $org | Remove-Org
            Assert-MockCalled Invoke-ApiRequest
        }
        It "ensures Org is specified" {
            {Remove-Org -Org $null } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
