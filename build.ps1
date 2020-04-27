$VerbosePreference = "continue"
((Get-Content -path ./hsdp-iam.nuspec -Raw) -replace '\${NUGET_VERSION}','99.99.99') | Set-Content -Path ./hsdp-iam.nuspec
((Get-Content -path ./hsdp-iam.psd1 -Raw) -replace '\${NUGET_VERSION}','99.99.99') | Set-Content -Path ./hsdp-iam.psd1
& mono $NUGET_EXE pack -NoPackageAnalysis
import-module -Name ./hsdp-iam -Force
