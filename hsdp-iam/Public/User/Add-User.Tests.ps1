Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-User.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-User" {
    BeforeAll {
        $response = [PSCustomObject]@{}
        $orgId = "1"
        $org = ([PSCustomObject]@{id = $orgId})
        $loginId = "userOne"
        $familyName = "User"
        $givenName = "One"
        $email = "user@mailinator.com"

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
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
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User"
        Mock Invoke-ApiRequest { $response }
    }

    Context "api" {
        It "invoke request" {
            $result = Add-User -Org $org -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootpath -and `
                $AddHsdpApiSignature -and `
                (Compare-Object $ValidStatusCodes @(201)) -eq $null -and
                $ProcessHeader -and `
                ($Body,$MatchBody | Test-Equality)
            }
            $result | Should -Be $response
        }
        It "extracts id from location header" {
            Add-User -Org $org -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                if (-not $ProcessHeader) { $false } else {
                    $headers = @(@{"location"=@("/authorize/identity/User/1")})
                    $newBody = Invoke-Command -ScriptBlock $ProcessHeader -ArgumentList $headers
                    $newBody.id -eq "1"
                }
            }
        }
    }
    Context "param" {
        It "supports value from pipeline " {
            $result = $org | Add-User -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName
            Should -Invoke Invoke-ApiRequest #-ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "supports by position" {
            $result = Add-User $org $loginId $email $givenName $familyName
            Should -Invoke Invoke-ApiRequest #-ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "ensures -Org not null" {
            { Add-User -Org $null -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "*'Org'. The argument is null. Provide a valid value for the argument, and then try running the command again."
        }
        It "ensures -LoginId not null" {
            { Add-User -Org $org -LoginId $null -Email $email -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "*'LoginId'. The argument is null or empty*"
        }
        It "ensures -LoginId not empty" {
            { Add-User -Org $org -LoginId "" -Email $email -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "*'LoginId'. The argument is null or empty*"
        }
        It "ensures -Email not null" {
            { Add-User -Org $org -LoginId $loginId -Email $null -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "*'Email'. The argument is null or empty*"
        }
        It "ensures -Email not empty" {
            { Add-User -Org $org -LoginId $loginId -Email "" -GivenName $givenName -FamilyName $familyName } `
                | Should -Throw "*'Email'. The argument is null or empty*"
        }
        It "ensures -GivenName not null" {
            { Add-User -Org $org -LoginId $loginId -Email $email -GivenName $null -FamilyName $familyName } `
                | Should -Throw "*'GivenName'. The argument is null or empty*"
        }
        It "ensures -GivenName not empty" {
            { Add-User -Org $org -LoginId $loginId -Email email -GivenName "" -FamilyName $familyName } `
                | Should -Throw "*'GivenName'. The argument is null or empty*"
        }
        It "ensure -FamilyName not null" {
            { Add-User -Org $org -LoginId $loginId -Email $email -GivenName $givenName -FamilyName $null } `
                | Should -Throw "*'FamilyName'. The argument is null or empty*"
        }
        It "ensure -FamilyName not empty" {
            { Add-User -Org $org -LoginId $loginId -Email email -GivenName $givenName -FamilyName "" } `
                | Should -Throw "*'FamilyName'. The argument is null or empty*"
        }
    }
}
