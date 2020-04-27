$VerbosePreference = "continue"
Push-Location $PSScriptRoot/src

if ((Get-Module -list -Name Pester) -notcontains 'pester') {
    Install-Module -Name Pester -SkipPublisherCheck -RequiredVersion 4.9.0 -Force
}

Invoke-Pester -ExcludeTag 'Disabled' -Script @{ Path = 'Public/*' } -OutputFile "./test-pester.xml" -OutputFormat 'NUnitXML'

Pop-Location