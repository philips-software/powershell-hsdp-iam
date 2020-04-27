param($branchName, $apikey)

Write-Verbose "Branch Name: $($branchName)"

$VERSION = "99.99.99"

$osEnv = (Get-ChildItem -Path ENV: | Where-Object { $_.name -eq 'OS'})
if ($osEnv -and $osEnv.Value -eq "Windows_NT" ) {
    Write-Verbose "Using windows nuget"
    & nuget push target/hsdp-iam.$VERSION.nupkg $apikey -Source https://api.nuget.org/v3/index.json
} else {
    Write-Verbose "Using mono for nuget"
    & mono $NUGET_EXE nuget push target/hsdp-iam.$VERSION.nupkg $apikey -Source https://api.nuget.org/v3/index.json
}

