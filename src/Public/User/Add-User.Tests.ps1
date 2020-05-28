$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Add-User.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Add-User" {
    $response = [PSCustomObject]@{}
    $orgId = "1"
    $org = ([PSCustomObject]@{id = $orgId})
    $loginId = "userOne"
    $familyName = "User"
    $givenName = "One"
    $email = "user@mailinator.com"

    $MatchBody = @{
        "resourceType"= "Person";
        "loginId"= $loginId;
        "managingOrganization"= $org.id;
        "name" = @{
            "family"= $familyName;
            "given"= $givenName;
        };
        "telecom" = @(
            @{
                "system"="email";
                "value"=$email;
            }
        );
        "isAgeValidated"= $true;
    }
    $rootPath = "/authorize/identity/User"

    Mock Invoke-ApiRequest { $response } 

    Context "Create a minimal user" {
        $result = Add-User -Org $org -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq $rootpath -and `
            $AddHsdpApiSignature -and `
            (Compare-Object $ValidStatusCodes @(200,201)) -eq $null -and
            $ProcessHeader -and `
            ($Body,$MatchBody | Test-Equality)
        }
        $result | Should -Be $response        
    }
    Context "extracts id from location header" {
        $result = Add-User -Org $org -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            if (-not $ProcessHeader) { $false } else {
                $headers = @(@{"location"=@("/authorize/identity/User/1")})
                $newBody = Invoke-Command -ScriptBlock $ProcessHeader -ArgumentList $headers
                $newBody.id -eq "1"
            }
        }
    }
    Context "parameters" {       
        It "support org from pipeline " {
            $result = $org | Add-User -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName
            Assert-MockCalled Invoke-ApiRequest #-ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "support parameters by position" {
            $result = Add-User $org $loginId $email $givenName $familyName
            Assert-MockCalled Invoke-ApiRequest #-ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "requires non-null org " {
            { Add-User -Org $null -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null. Provide a valid value for the argument, and then try running the command again."
        }
        It "requires non-null loginId" {
            { Add-User -Org $org -LoginId $null -Email $email -MobilePhone $mobilePhone -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'LoginId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-empty loginId" {
            { Add-User -Org $org -LoginId "" -Email $email -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'LoginId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-null Email" {
            { Add-User -Org $org -LoginId $loginId -Email $null -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'Email'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-empty Email" {
            { Add-User -Org $org -LoginId $loginId -Email "" -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'Email'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-null GivenName" {
            { Add-User -Org $org -LoginId $loginId -Email $email -GivenName $null -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'GivenName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-empty GivenName" {
            { Add-User -Org $org -LoginId $loginId -Email email -GivenName "" -FamilyName $familyName } `
                | Should -Throw "Cannot validate argument on parameter 'GivenName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-null FamilyName" {
            { Add-User -Org $org -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $null } `
                | Should -Throw "Cannot validate argument on parameter 'FamilyName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "requires non-empty FamilyName" {
            { Add-User -Org $org -LoginId $loginId -Email email -GivenName $givenName -FamilyName "" } `
                | Should -Throw "Cannot validate argument on parameter 'FamilyName'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
