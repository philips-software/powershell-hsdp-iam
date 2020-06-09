<#
    .SYNOPSIS
    Retrieve organizations based on filter criteria.

    .DESCRIPTION
    Retrieves all organizations registered under a specific parent organization. The parent organization can be passed as filter parameter.
    If no filter is passed, this API will return all child organizations under the requester's organization. A OAuth2.0 Bearer token of
    a subject with HSDP_IAM_ORGANIZATION.READ permission is required to perform only this operation.

    .OUTPUTS
    Array of organization resource objects

    .PARAMETER MyOrgOnly
    Specifies to retrieve the current user's organization

    .PARAMETER Name
    Returns only organizations matching this name

    .PARAMETER ParentOrg
    Returns only organizations with the specified parent org resource object

    .PARAMETER Inactive
    Specifies to only return inactive organizations

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/get_Organizations

    .EXAMPLE
    Get-Orgs | Select-Object -First 1

    .EXAMPLE
    Get-Orgs -MyOrgOnly

    .EXAMPLE
    Get-Orgs -Filter "parent.value eq ""e5550a19-b6d9-4a9b-ac3c-10ba817776d4"""

    .NOTES
    GET: /Organizations v2
    Only the first 10000 organizations will be returned.
#>
function Get-Orgs {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Switch]
        [Parameter(Mandatory=$false)]
        $MyOrgOnly,

        [Parameter(Mandatory=$false)]
        [String]$Name,

        [Parameter(Mandatory=$false)]
        [PSObject]$ParentOrg,

        [Parameter(Mandatory=$false)]
        [Switch]$Inactive
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $p = @{ Index = 1; Size = 100}
        if ($MyOrgOnly) {
            $p.MyOrgOnly = $MyOrgOnly
        }
        if ($Name) {
            $p.Name = $Name
        }
        if ($ParentOrg) {
            $p.ParentOrg = $ParentOrg
        }
        if ($Inactive) {
            $p.Inactive = $Inactive
        }
        do {
            Write-Verbose "Index # $($p.Index)"
            $response = (Get-OrgsByPage @p)
            Write-Output ($response.Resources)
            $p.Index += $p.Size
        } while (($response.itemsPerPage -eq $p.Size))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}