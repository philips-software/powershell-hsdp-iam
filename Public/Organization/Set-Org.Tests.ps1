$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Set-Org.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Set-Org" {
    $response = [PSCustomObject]@{}
    $Org = @{ "id" = "2"; }
    $response = @{}
    Mock Invoke-ApiRequest { $response }        
    $rootPath = "/authorize/scim/v2/Organizations"

    Context "Set minimal org" {
        # Act
        $updated = Set-Org $Org
        # Assert
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq "$($rootPath)/$($Org.id)" -and `
            $Version -eq 2 -and `
            $Method -eq "Put" -and `
            $AddIfMatch -ne $null -and `
            (Compare-Object $ValidStatusCodes @(200)) -eq $null
        }
        $updated | Should -Be $response
    }
    Context "parameters" {       
        It "support parent org from pipeline " {
            $updated =  $Org | Set-Org
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($Org.id)" }
            $updated | Should -Be $response
        }        
    }
}