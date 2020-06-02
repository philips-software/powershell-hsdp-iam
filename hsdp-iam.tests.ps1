$VerbosePreference = "silentlycontinue"
function Install-ModuleVersion($Name, $Version) {
    if ((Get-Module -list -Name $Name | where { $_.version -eq $Version }) -notcontains $Name) {
        Install-Module -Name $Name -SkipPublisherCheck -RequiredVersion $Version -Force
    }
}

Install-ModuleVersion -Name "Pester" -Version "5.0.1"
Install-ModuleVersion -Name "Functional" -Version "0.0.4"
Install-ModuleVersion -Name "PesterMatchHashTable" -Version "0.3.0"
Install-ModuleVersion -Name "PesterMatchArray" -Version "0.3.1"

Invoke-Pester -ExcludeTag 'Disabled' -Path "src/*" -OutputFile "./test-pester.xml" -OutputFormat NUnitXml

# Determine all the cmdlets that do not have matching *.Tests.ps1 files
$allFiles = Get-ChildItem src/public/*.ps1 -Recurse
$notTestFiles = $allFiles | Where-Object { $_.name -notlike "*.Tests.ps1"}
$cmdletsFiles  = $notTestFiles | Select-Object @{Name="name";Expression={$_.Name -replace ".ps1",""}} | Sort-Object name
$cmdletNames = $cmdletsFiles | Sort-Object name | select-object -ExpandProperty Name

$testFiles = $allFiles | Where-Object { $_.name -like "*.Tests.ps1"}
$testCmdLetFiles = $testFiles | Select-Object @{Name="name";Expression={($_.Name -replace ".ps1","") -replace ".Tests",""}} | Sort-Object name
$testCmdLetNames = $testCmdLetFiles | Sort-Object name | select-object -ExpandProperty Name

$cmdLetsWithoutTests = Compare-Object -ReferenceObject $cmdletNames -DifferenceObject $testCmdLetNames
if ($cmdLetsWithoutTests) {
    $cmdLetsWithoutTests | ForEach-Object { Write-Warning "$($_.InputObject) cmdlet does not have test file in the format '$($_.InputObject).Tests.ps1'" }
}