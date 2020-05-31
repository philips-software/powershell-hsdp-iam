param($major = "0", $minor = "1", $patch = "0")

Push-Location $PSScriptRoot/src

Invoke-ScriptAnalyzer -Path Public -Recurse

# ensure the module imports
Import-Module -Name ./hsdp-iam -Force

$semver = "$($major).$($minor).$($patch)"
Write-Verbose "Setting version to $($semver)"

((Get-Content -path hsdp-iam-template.nuspec -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path hsdp-iam.nuspec
((Get-Content -path hsdp-iam-template.psd1 -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path hsdp-iam.psd1

$osEnv = (Get-ChildItem -Path ENV: | Where-Object { $_.name -eq 'OS'})
if ($osEnv -and $osEnv.Value -eq "Windows_NT" ) {
    Write-Verbose "Using windows nuget"
    & nuget pack hsdp-iam.nuspec -NoPackageAnalysis -OutputDirectory $PSScriptRoot/target
}

Pop-Location