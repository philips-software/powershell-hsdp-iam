<#
    .SYNOPSIS
    Imports users to groups using multiple .csv files

    .DESCRIPTION
    This is a utility cmdlet to allow batch adding of users into groups in orgs.
    All users will be placed in the group in all the orgs specified.

    .PARAMTER OrgCsvFileName
    The csv file containing org identifier per line.

    .PARAMTER UserCsvFileName
    The csv file containing a user identifier per line.

    .PARAMTER GroupName
    The group name to add the users.

    .EXAMPLE
    Import-UsersToOrgGroups
#>
function Import-UsersToOrgGroups {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgCsvFileName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$UserCsvFileName,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Information "Begin import of '$($UserCsvFileName)' and '$($OrgCsvFileName)' into group '$($GroupName)'"
        $orgIds = Import-Csv -Path $OrgCsvFileName -Header A | Select-Object -Unique A -ExpandProperty A
        $userIds = Import-Csv -Path $UserCsvFileName -Header A | Select-Object -Unique A -ExpandProperty A
        Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $GroupName
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}