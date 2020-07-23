Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Invoke-ApiRequest.ps1"
    . "$PSScriptRoot\Get-Config.ps1"
    . "$PSScriptRoot\..\OAuth2\Get-AuthorizationHeader.ps1"
}

Describe "Invoke-ApiRequest" {
    Context "test" {
        BeforeAll {
            $content = [PSCustomObject]@{foo="bar"; "meta"=@{"version"="1234"}}
            $response = @{
                StatusCode = 200;
                Headers = @{
                    "ETag"="1234"
                }
                Content = ($content | ConvertTo-Json)
            }
            Mock Invoke-WebRequest { $response }
            Mock Get-Variable
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $Base = "http://localhost"
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $Path = "/foo"
            Mock Get-AuthorizationHeader { "12345" }
        }
        It "calls Invoke-WebRequest with minial parameters" {
            $response = Invoke-ApiRequest -Base $Base -Path $Path
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Uri -eq "$($Base)$($Path)" -and `
                $Method -eq "Get" -and `
                $Headers["api-version"] -eq "1" -and `
                $Headers["Content-Type"] -eq "application/json" -and
                $Body -eq $response.Content -and `
                $ErrorAction -eq "Stop"
            }
            Write-Debug ($response | ConvertTo-Json)
            Write-Debug ($content | ConvertTo-Json)
            $response.foo | Should -Be $content.foo
            $response.meta.version | Should -Be $content.meta.version
        }
        It "uses config basepath -Base not specified" {
            $Base = "https://boop"
            $config = @{"IdmUrl" = $Base}
            Mock Get-Config { $config }
            Invoke-ApiRequest -Path $Path
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Uri -eq "$($Base)$($Path)"
            }
        }
        It "adds authorization header" {
            $Authorization = "Bearer 1234"
            Invoke-ApiRequest -Base $Base -Path $Path -Authorization $Authorization
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Headers["Authorization"] -eq $Authorization
            }
        }
        It "does not convert body from PSObject when content is not application/json" {
            Invoke-ApiRequest -Base $Base -Path $Path -ContentType "string" -Body "aaa"
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Body -eq "aaa"
            }
        }
        It "no body" {
            Invoke-ApiRequest -Base $Base -Path $Path
            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Body -eq $null
            }
        }
    }
}

