<#
    .SYNOPSIS
    A utility to tests that organization identifiers are valid.

    .DESCRIPTION
    This utility function can be used to validate input from scripts or users.
    
    .INPUTS
    An array of organization ids

    .OUTPUTS
    A boolean indicating if all the ids are valid.

    .PARAMETER OrgIds
    An array of organization ids

    .EXAMPLE
    Test-OrgIds @("02bdfa45-db4b-4450-a77e-b59ab9df9472", "ccc5ddd3-5355-4a81-81a6-7188ce150401")
#>
function Test-OrgIds  {

    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [array]$OrgIds
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        
        $orgs = Get-Orgs
        $valid = $true
        $OrgIds | ForEach-Object {
            $orgId = $_
            if (-not ($orgs | Where-Object { $_.id -eq $orgId })) {
                $valid = $false
                Write-Warning "org '$($orgId)' is not a valid id"
            }
        }
        Write-Output $valid    
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}