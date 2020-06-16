Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-PasswordPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-PasswordPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/PasswordPolicy"
        $response = @{}
        Mock Invoke-ApiRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $MinBody = @{
            managingOrganization = $Org.Id;
            expiryPeriodInDays   = 1095;
            historyCount         = 1;
            complexity           = @{
                minLength       = 8;
                maxLength       = 256;
                minNumerics     = 0;
                minUpperCase    = 0;
                minLowerCase    = 0;
                minSpecialChars = 0;
            }
        }
    }
    Context "api" {
        It "invokes request with min/default parameters" {
            $added = Add-PasswordPolicy -Org $org
            $added | Should -Be $response
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                    $Version -eq 1 -and `
                    $Method -eq "Post" -and `
                ($MinBody, $Body | Test-Equality)
            }
        }
        It "invokes request with all parameters" {
            $added = Add-PasswordPolicy -Org $org -ExpiryPeriodInDays 2 -HistoryCount 3 -MinLength 9 -MaxLength 10 `
                -MinNumerics 11 -MinUpperCase 12 -MinLowerCase 13 -MinSpecialChars 14 `
                -ChallengesEnabled -DefaultQuestions @("color") -MinQuestionCount 1 -MinAnswerCount 1 -MaxIncorrectAttempts 2
            $added | Should -Be $response
            $MaxBody = @{
                managingOrganization = $Org.Id;
                expiryPeriodInDays   = 2;
                historyCount         = 3;
                complexity           = @{
                    minLength       = 9;
                    maxLength       = 10;
                    minNumerics     = 11;
                    minUpperCase    = 12;
                    minLowerCase    = 13;
                    minSpecialChars = 14;
                }
                challengesEnabled = "true";
                challengePolicy = @{
                    defaultQuestions = @("color");
                    minQuestionCount = 1;
                    minAnswerCount = 1;
                    maxIncorrectAttempts = 2;
                }
            }
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                    $Version -eq 1 -and `
                    $Method -eq "Post" -and `
                ($MaxBody, $Body | Test-Equality)
            }
        }

    }
    Context "param" {
        It "value from pipeline " {
            $org | Add-PasswordPolicy
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            { Add-PasswordPolicy -Org $null } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -ChallengesEnabled required -DefaultQuestions" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled } | Should -Throw "*Must specify -DefaultQuestions if -ChallengesEnabled*"
        }
        It "ensures -ChallengesEnabled required -MinQuestionCount" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1}} | Should -Throw "*Must specify -MinQuestionCount if -ChallengesEnabled*"
        }
        It "ensures -ChallengesEnabled required -MinAnswerCount" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1} -MinQuestionCount 1} | Should -Throw "*Must specify -MinAnswerCount if -ChallengesEnabled*"
        }
        It "ensures -ChallengesEnabled required -MaxIncorrectAttempts" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1} -MinQuestionCount 1 -MinAnswerCount 1} | Should -Throw "*Must specify -MaxIncorrectAttempts if -ChallengesEnabled*"
        }
        It "ensures -MinQuestionCount less or equal to -DefaultQuestions length" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1} -MinQuestionCount 2 -MinAnswerCount 1 -MaxIncorrectAttempts 1} | Should -Throw "*-MinQuestionCount must be less than or equal to -DefaultQuestions length*"
        }
        It "ensures -MinAnswerCount less or equal to -MinQuestionCount length" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1} -MinQuestionCount 1 -MinAnswerCount 2 -MaxIncorrectAttempts 1} | Should -Throw "*-MinAnswerCount must be less or equal to -MinQuestionCount*"
        }
        It "ensures -MinQuestionCount only allowed when -ChallengesEnabled" {
            { Add-PasswordPolicy -Org $org -MinQuestionCount 1 } | Should -Throw "*Must specify -ChallengesEnabled if specifying -MinQuestionCount, -MinAnswerCount or -MaxIncorrectAttempts*"
        }
        It "ensures -MinAnswerCount only allowed when -ChallengesEnabled" {
            { Add-PasswordPolicy -Org $org -MinAnswerCount 1 } | Should -Throw "*Must specify -ChallengesEnabled if specifying -MinQuestionCount, -MinAnswerCount or -MaxIncorrectAttempts*"
        }
        It "ensures -MaxIncorrectAttempts only allowed when -ChallengesEnabled" {
            { Add-PasswordPolicy -Org $org -MinAnswerCount 1 } | Should -Throw "*Must specify -ChallengesEnabled if specifying -MinQuestionCount, -MinAnswerCount or -MaxIncorrectAttempts*"
        }
        It "validates range for -ExpiryPeriodInDays" {
            { Add-PasswordPolicy -Org $org -ExpiryPeriodInDays 0 } | Should -Throw "*'ExpiryPeriodInDays'. The 0 argument is less than the minimum allowed range of 1*"
            { Add-PasswordPolicy -Org $org -ExpiryPeriodInDays 1096 } | Should -Throw "*'ExpiryPeriodInDays'. The 1096 argument is greater than the maximum allowed range of 1095*"
        }
        It "validates range for -HistoryCount" {
            { Add-PasswordPolicy -Org $org -HistoryCount 0 } | Should -Throw "*'HistoryCount'. The 0 argument is less than the minimum allowed range of 1*"
            { Add-PasswordPolicy -Org $org -HistoryCount 11 } | Should -Throw "*'HistoryCount'. The 11 argument is greater than the maximum allowed range of 10*"
        }
        It "validates range for -MinLength" {
            { Add-PasswordPolicy -Org $org -MinLength 7 } | Should -Throw "*'MinLength'. The 7 argument is less than the minimum allowed range of 8*"
            { Add-PasswordPolicy -Org $org -MinLength 257 } | Should -Throw "*'MinLength'. The 257 argument is greater than the maximum allowed range of 256*"
        }
        It "validates range for -MaxLength" {
            { Add-PasswordPolicy -Org $org -MaxLength 7 } | Should -Throw "*'MaxLength'. The 7 argument is less than the minimum allowed range of 8*"
            { Add-PasswordPolicy -Org $org -MaxLength 257 } | Should -Throw "*'MaxLength'. The 257 argument is greater than the maximum allowed range of 256*"
        }
        It "validates range for -MinNumerics" {
            { Add-PasswordPolicy -Org $org -MinNumerics -1 } | Should -Throw "*'MinNumerics'. The -1 argument is less than the minimum allowed range of 0*"
            { Add-PasswordPolicy -Org $org -MinNumerics 257 } | Should -Throw "*'MinNumerics'. The 257 argument is greater than the maximum allowed range of 256*"
        }
        It "validates range for -MinUpperCase" {
            { Add-PasswordPolicy -Org $org -MinUpperCase -1 } | Should -Throw "*'MinUpperCase'. The -1 argument is less than the minimum allowed range of 0*"
            { Add-PasswordPolicy -Org $org -MinUpperCase 257 } | Should -Throw "*'MinUpperCase'. The 257 argument is greater than the maximum allowed range of 256*"
        }
        It "validates range for -MinQuestionCount" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1;b=2;c=3;d=4;e=5} -MinQuestionCount 0 -MinAnswerCount 1 -MaxIncorrectAttempts 1 -MinAnswerCount 1 } | Should -Throw "*'MinQuestionCount'. The 0 argument is less than the minimum allowed range of 1*"
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1;b=2;c=3;d=4;e=5} -MinQuestionCount 6 -MinAnswerCount 1 -MaxIncorrectAttempts 1 -MinAnswerCount 1 } | Should -Throw "*'MinQuestionCount'. The 6 argument is greater than the maximum allowed range of 5*"
        }
        It "validates range for -MinAnswerCount" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1;b=2;c=3;d=4;e=5} -MinQuestionCount 1 -MinAnswerCount 0 -MaxIncorrectAttempts 1 -MinAnswerCount 1 } | Should -Throw "*'MinAnswerCount'. The 0 argument is less than the minimum allowed range of 1*"
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1;b=2;c=3;d=4;e=5} -MinQuestionCount 1 -MinAnswerCount 6 -MaxIncorrectAttempts 1 -MinAnswerCount 1 } | Should -Throw "*'MinAnswerCount'. The 6 argument is greater than the maximum allowed range of 5*"
        }
        It "validates range for -MaxIncorrectAttempts" {
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1;b=2;c=3;d=4;e=5} -MinQuestionCount 1 -MinAnswerCount 1 -MaxIncorrectAttempts 0 -MinAnswerCount 1 } | Should -Throw "*'MaxIncorrectAttempts'. The 0 argument is less than the minimum allowed range of 1*"
            { Add-PasswordPolicy -Org $org -ChallengesEnabled -DefaultQuestions @{a=1;b=2;c=3;d=4;e=5} -MinQuestionCount 1 -MinAnswerCount 1 -MaxIncorrectAttempts 6 -MinAnswerCount 1 } | Should -Throw "*'MaxIncorrectAttempts'. The 6 argument is greater than the maximum allowed range of 5*"
        }
   }
}