$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-MFAPolicy.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Remove-MFAPolicy" {
    $policy = ([PSCustomObject]@{id = "1"})
    $response = [PSCustomObject]@{}
    Mock Invoke-ApiRequest { $response }
    $rootPath = "/authorize/scim/v2/MFAPolicies"
    Context "remove a policy" {
        $result = Remove-MFAPolicy -Policy $policy
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq "$($rootPath)/$($policy.id)" -and `
            $Version -eq 2 -and `
            $Method -eq "Delete" -and `
            $ValidStatusCodes -eq 204
        }
        $result | Should -Be $response
    }
    Context "parameters" {       
        It "support Policy from pipeline " {
            $result = $policy | Remove-MFAPolicy 
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($policy.id)" }
        }
        It "ensures Policy is specified" {
            {Remove-MFAPolicy -Policy $null } | Should -Throw "Cannot validate argument on parameter 'Policy'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
