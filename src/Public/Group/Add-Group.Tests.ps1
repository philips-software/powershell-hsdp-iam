Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Add-Group.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Group" {    
    BeforeAll {
        $rootPath = "/authorize/identity/Group"
    }
    Context "api" {
        It "invoke request" {
            $org = ([PSCustomObject]@{id = "1"})
            $response = @{}
            Mock Invoke-ApiRequest { $response }
            Add-Group -Org $org -Name "foo" -Description "bar"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {            
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                $Body.name -eq "foo" -and `
                $Body.managingOrganization -eq "1" -and
                $Body.description -eq "bar"
            }
        }
    }
    Context "param" {       
        BeforeAll {
            $org = ([PSCustomObject]@{id = "1"})
        }
        It "accepts value from pipeline" {
            $response = @{}
            Mock Invoke-ApiRequest { $response }
            $org | Add-Group -Name "foo"
            Should -Invoke Invoke-ApiRequest
        }        
        It "ensures -Org not null" {
            {Add-Group -Org $null } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            {Add-Group -Org $Org -Name $null } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            {Add-Group -Org $org -Name "" } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "supports by position" {
            $response = @{}
            Mock Invoke-ApiRequest { $response }
            Add-Group $org "foo" "bar"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {            
                $Body.managingOrganization -eq "1" -and `
                $Body.name -eq "foo" -and `
                $Body.description -eq "bar"
            }
        }
    }
}