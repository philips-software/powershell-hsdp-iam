Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Remove-Group.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Import-Module PesterMatchHashtable -PassThru

Describe "Remove-Group" {
    BeforeAll {
        $group = ([PSCustomObject]@{id = "1"})
        $rootPath = "/authorize/identity/Group"
        Mock Invoke-ApiRequest    
    }
    Context "api" {        
        It "invoke request" {
            Remove-Group -Group $group
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq "$($rootPath)/$($group.id)") -and `
                    ($Method -eq "Delete") -and `
                    ($Version -eq "1") -and `  
                    ((Compare-Object $ValidStatusCodes @(204)) -eq $null)
            }            
        }
    }
    Context "param" {       
        It "accepts value from pipeline" {
            $group | Remove-Group
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Remove-Group -Group $null } | Should -Throw "*'Group'. The argument is null or empty*"
        }
    }
}
