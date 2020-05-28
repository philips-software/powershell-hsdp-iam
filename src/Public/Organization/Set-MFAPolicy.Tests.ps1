$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Set-MFAPolicy.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Set-MFAPolicy" {
    $policy = ([PSCustomObject]@{id = "1"})
    $response = [PSCustomObject]@{}
    Mock Invoke-ApiRequest { $response }
    $rootPath = "/authorize/scim/v2/MFAPolicies"
    Context "update a policy" {
        $result = Set-MFAPolicy -Policy $policy
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq "$($rootPath)/$($policy.id)" -and `
            $Method -eq "Put" -and `
            $AddIfMatch -eq $true -and 
            ($Body, $policy | Test-Equality) -and
            $Version -eq 2 -and `
            $ValidStatusCodes -eq 200
        }
        $result | Should -Be $response
    }
    Context "parameters" {       
        It "support Policy from pipeline " {
            $result = $policy | Set-MFAPolicy 
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($policy.id)" }
        }
        It "ensures Policy is specified" {
            {Set-MFAPolicy -Policy $null } | Should -Throw "Cannot validate argument on parameter 'Policy'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
