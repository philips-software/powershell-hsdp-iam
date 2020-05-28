<#
    .SYNOPSIS
    A utility to tests that organization identifiers are valid.

    .DESCRIPTION
    This utility function can be used to validate input from scripts or users.
    
    .INPUTS
    An array of organization ids

    .OUTPUTS
    An array of invalid org ids ids

    .PARAMETER Ids
    An array of organization ids

    .EXAMPLE
    $invalidOrgs = Test-OrgIds @("02bdfa45-db4b-4450-a77e-b59ab9df9472", "ccc5ddd3-5355-4a81-81a6-7188ce150401")
#>
function Test-OrgIds  {

    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Ids
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        
        $orgs = Get-Orgs
        [string[]]$invalid = @()
        $Ids | ForEach-Object {
            $id = $_
            if (-not ($orgs | Where-Object { $_.id -eq $id })) {
                $invalid += $id
                Write-Warning "org '$($id)' is not a valid id"
            }
        }        
        Write-Output @($invalid)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}