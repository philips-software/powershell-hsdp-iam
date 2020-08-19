<#
    .SYNOPSIS
    Retrieves auth policies by org or policy set id

    .DESCRIPTION
    Retrieves all policies based on the filter specified. If organizationId is not passed, then requestor's managing organization will be considered.
    This API will return a maximum of 100 policies. An OAuth2.0 token is required with the following permission - POLICY.WRITE

    .INPUTS
    Accepts the Org object from the pipeline

    .OUTPUTS
    Returns an array of auth policy objects

    .PARAMETER Org
    The organization PSObject

    .PARAMETER PolicySetId
    The policy set identifier

    .EXAMPLE
    $authPolicies = Get-AuthPolicies -Org (Get-Org -MyOrgOnly)

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/policy-provisioning-api#/Policy/get_authorize_access_Policy

    .NOTES
    GET /authorize/access/Policy v1
#>
function Get-AuthPolicies {

    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$PolicySetId
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Org) {
            $params = "organizationId=$($Org.id)"
        }
        if ($PolicySetId) {
            if ($Org) {
                $params += "&"
            }
            $params += "policySetId=$($PolicySetId)"
        }
        Write-Output (Invoke-GetRequest "/authorize/access/Policy?$($params)" -Version 1).entry
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}