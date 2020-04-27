param($semver = "PullRequest")

$VerbosePreference = "continue"

Push-Location $PSScriptRoot/src

if ($semver -contains "PullRequest") {
    Write-Verbose "Pull request"
    $semver = "99.99.99"
}

Write-Verbose "semver: $($semver)"

# ensure the module imports
Import-Module -Name ./hsdp-iam -Force

Write-Verbose "Setting version"
((Get-Content -path hsdp-iam-template.nuspec -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path hsdp-iam.nuspec
((Get-Content -path hsdp-iam-template.psd1 -Raw) -replace '\${NUGET_VERSION}',$semver) | Set-Content -Path hsdp-iam.psd1

$osEnv = (Get-ChildItem -Path ENV: | Where-Object { $_.name -eq 'OS'})
if ($osEnv -and $osEnv.Value -eq "Windows_NT" ) {
    Write-Verbose "Using windows nuget"
    & nuget pack hsdp-iam.nuspec -NoPackageAnalysis -OutputDirectory $PSScriptRoot/target
}

Pop-Location