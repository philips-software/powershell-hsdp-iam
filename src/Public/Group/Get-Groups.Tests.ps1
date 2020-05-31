Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Groups.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Groups" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Group?"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = [PSCustomObject]@{ "Id" = "1" }
        $resource = @{
            "resourceType"="Group";
            "groupDescription"="HSDP Foundation Audit query access";
            "groupName"= "AuditorsGroup";
            "orgId"="e5550a19-b6d9-4a9b-ac3c-10ba817776d4";
            "_id"="4770b86c-cc56-4487-8005-0b33f0899158";
        }
        $response = @{"entry" = @(@{"resource"=$resource})}
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Get-Groups -Org $org
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)organizationId=$($Org.id)" -and $Version -eq 1
            }
            $expectedResult = [PSCustomObject]@{
                name="AuditorsGroup";
                description="HSDP Foundation Audit query access";
                managingOrganization="e5550a19-b6d9-4a9b-ac3c-10ba817776d4";
                id="4770b86c-cc56-4487-8005-0b33f0899158"
            }
            ($result, $expectedResult | Test-Equality) | Should -BeTrue
        }
        It "by name" {
            Get-Groups -Org $org -Name "foo"
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)organizationId=$($Org.id)&name=foo"
            }
        }
        It "by memberType" {
            Get-Groups -Org $org -MemberType "DEVICE" -MemberId "foo"
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)organizationId=$($Org.id)&memberType=DEVICE&memberId=foo"
            }
        }
    }
    Context "param" {
        It "supports positional" {
            Get-Groups $org "foo"
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)organizationId=$($Org.id)"
            }
        }
        It "accepts org from pipeline" {
            $org | Get-Groups
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)organizationId=$($Org.id)"
            }
        }
        It "ensures -Org not null" {
            { Get-Groups -Org $null } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -MemberType is valid value" {
            { Get-Groups -Org $org -MemberType "USER" -MemberId "1" } | Should -Not -Throw
            { Get-Groups -Org $org -MemberType "DEVICE" -MemberId "1" } | Should -Not -Throw
            { Get-Groups -Org $org -MemberType "SERVICE" -MemberId "1" } | Should -Not -Throw
            { Get-Groups -Org $org -MemberType "FOO" -MemberId "1" } | Should -Throw "*'MemberType'. The argument `"FOO`" does not belong to the set `"USER,DEVICE,SERVICE`"*"
        }
        It "ensures -MemberType and -MemberId are specified together" {
            { Get-Groups -Org $org -MemberType "USER" } | Should -Throw "If either MemberType or MemberId is supplied then both must be supplied"
            { Get-Groups -Org $org -MemberId "1" } | Should -Throw "If either MemberType or MemberId is supplied then both must be supplied"
        }
    }
}