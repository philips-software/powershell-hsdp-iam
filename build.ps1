param($major = "0", $minor = "1", $patch = "0", $Test = $true, $Analyze = $True)

$ErrorActionPreference = "stop"

if ($Test) {
    & .\hsdp-iam.tests.ps1
}

# run unit tests
Push-Location $PSScriptRoot/hsdp-iam

if ($Analyze) {
    Install-Module -Name PSScriptAnalyzer -Force
    Invoke-ScriptAnalyzer -Path Public -Recurse
}

# ensure the module imports
Import-Module -Name ./hsdp-iam -Force

$semver = "$($major).$($minor).$($patch)"
Write-Verbose "Setting version to $($semver)"

((Get-Content -path hsdp-iam-template.nuspec -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path hsdp-iam.nuspec
((Get-Content -path hsdp-iam-template.psd1 -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path hsdp-iam.psd1

Pop-Location