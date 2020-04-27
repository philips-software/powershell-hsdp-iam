$VerbosePreference = "continue"
Push-Location $PSScriptRoot/src

# ensure the module imports
Import-Module -Name ./hsdp-iam -Force

$VERSION = "99.99.99"
Write-Verbose "Setting version to $VERSION"
((Get-Content -path hsdp-iam-template.nuspec -Raw) -replace '\${NUGET_VERSION}',$VERSION) | Set-Content -Path hsdp-iam.nuspec
((Get-Content -path hsdp-iam-template.psd1 -Raw) -replace '\${NUGET_VERSION}',$VERSION) | Set-Content -Path hsdp-iam.psd1

$osEnv = (Get-ChildItem -Path ENV: | Where-Object { $_.name -eq 'OS'})
if ($osEnv -and $osEnv.Value -eq "Windows_NT" ) {
    & nuget pack hsdp-iam.nuspec -NoPackageAnalysis -OutputDirectory $PSScriptRoot/target
} else {
    & mono $NUGET_EXE pack hsdp-iam.nuspec -NoPackageAnalysis -OutputDirectory $PSScriptRoot/target
}

Pop-Location