$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Add-Group.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Add-Group" {    
    $rootPath = "/authorize/identity/Group"
    Context "Create a group" {
        $org = ([PSCustomObject]@{id = "1"})
        $response = @{}
        Mock Invoke-ApiRequest { $response }
        Add-Group -Org $org -Name "foo" -Description "bar"
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {            
            $Path -eq $rootPath -and `
            $Version -eq 1 -and `
            $Method -eq "Post" -and `
            $Body.name -eq "foo" -and `
            $Body.managingOrganization -eq "1" -and
            $Body.description -eq "bar"
        }
    }
    Context "parameters" {       
        $org = ([PSCustomObject]@{id = "1"})
        It "support Org from pipeline " {
            $response = @{}
            Mock Invoke-ApiRequest { $response }
            $org | Add-Group -Name "foo"
            Assert-MockCalled Invoke-ApiRequest
        }        
        It "ensures 'Org' is not null" {
            {Add-Group -Org $null } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty"
        }
        It "ensures 'Name' is not null" {
            {Add-Group -Org $Org -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "ensures 'Name' is not empty" {
            {Add-Group -Org $org -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "support params by position" {
            $response = @{}
            Mock Invoke-ApiRequest { $response }
            Add-Group $org "foo" "bar"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter {            
                $Body.managingOrganization -eq "1" -and `
                $Body.name -eq "foo" -and `
                $Body.description -eq "bar"
            }
        }
    }
}