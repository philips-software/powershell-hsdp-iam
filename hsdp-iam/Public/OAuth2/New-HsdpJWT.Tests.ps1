Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\New-HsdpJWT.ps1"
    . "$PSScriptRoot\..\Utility\Get-Config.ps1"
}

Describe "New-HsdpJWT" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $service = @{"serviceId"="1"}
        $url = "http://localhost"
        Mock Get-Config { @{IamUrl=$url} }

        $buffer = [System.Byte[]]::new(10)
        $Random = [System.Random]::new()
        $Random.NextBytes($buffer)

        Mock Get-Content { $buffer }
        Mock New-JWT { "bbbbb" }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $keyFile = "keyfile"
    }
    Context "api" {
        It "new jwt" {
            New-HsdpJWT -Service $service -KeyFile $keyFile
        }
    }
}
