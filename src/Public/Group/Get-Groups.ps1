<#
    .SYNOPSIS
    Retrieves Group(s) based on a set of parameters.

    .DESCRIPTION
    Retrieves one or more Group resources found under a given parent Organization and matches given search parameters. 
    A user with GROUP.READ will be allowed to retrieve groups from an organization. For query by memberId of an identity
    that is assigned across organizations (such as SERVICE), this API retrieves all groups assigned to the identity irrespective of organization.
    Note:
        - Only users having administrator permissions on the parent Group can list the sub groups.
        - Search set shall contain child Groups found under the requested parent organization (non-recursive).
        - Any unknown parameters shall be ignored.

    .INPUTS
    Accepts the organization object

    .OUTPUTS
    An array of organization objects

    .PARAMETER Org
    The organization object 

    .PARAMETER Name
    An optional group name to use as filter 

    .PARAMETER MemberType
    Filter by memeber type of either 'USER', 'DEVICE' or 'SERVICE'

    .PARAMETER MemberId
    Filter by members with this identifier

    .EXAMPLE
    $org = Get-Orgs | select-object -first 1
    $groups = $org | Get-Groups 

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/get_authorize_identity_Group

    .NOTES
    GET: GET: /authorize/identity/Group v1
    The API does does not support searching for group names that contain a space or special characters
    This API returns a different object than the POST/GET methods. e.g. _id instead of id, "groupName" instead of "name"
#>
function Get-Groups {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory = $false, Position = 1)]
        [String]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateSet('USER', 'DEVICE', 'SERVICE')]        
        [String]$MemberType,

        [Parameter(Mandatory = $false)]        
        [String]$MemberId
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $params = "organizationId=$($Org.id)"
        if ($Name) {
            $params += "&name=$($Name)"
        }
        if ($MemberType -and $MemberId) {
            $params += "&memberType=$($MemberType)&memberId=$($MemberId)"
        }
        $response = (Invoke-GetRequest "/authorize/identity/Group?$($params)" -Version 1).entry | Select-Object -ExpandProperty resource
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}