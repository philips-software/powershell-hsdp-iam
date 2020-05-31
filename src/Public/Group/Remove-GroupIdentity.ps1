<#
    .SYNOPSIS
    Remove identity from a group

    .DESCRIPTION
    Removes an identity from a group. This will delete all privileges the member got through group membership. 
    A user with GROUP.WRITE permission will be allowed to do this operation.
    
    Supported member types are - DEVICE, SERVICE
    Note: Maximum of 10 members can be removed using this resource in one call.

    .INPUTS
    Accepts the group object

    .OUTPUTS
    The updated group object. Must use this object for subsequent requests to meta.version is correct.

    .PARAMETER Group
    The group object 

    .PARAMETER Ids
    An array of identifiers to remove from the group

    .PARAMETER MemberType
    The member type of either "SERVICE" or "DEVICE". Defaults to "SERVICE"

    .EXAMPLE
    $group = Get-Group -Id "6ec094e1-73bf-4cfc-9a4e-5a17b577a3d1"    
    $group = Remove-GroupIdentity -Group $group -Ids @("1e9789bc-7267-4e94-9745-a3457adfd225")

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___remove

    .NOTES
    POST: /authorize/identity/Group/{id}/$remove v1
#>
function Remove-GroupIdentity {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(   
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Group,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Array]
        $Ids,

        [Parameter(Position = 2)]
        [ValidateSet("SERVICE", "DEVICE")]
        [String]
        $MemberType = "SERVICE"
    )
 
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # API documents show that it can support multiple roles assigned but only one is supported.
        $body = @{
            "memberType" = $MemberType;
            "value"      = $Ids;
        }
        if ($Group.meta -eq $null || $Group.meta.version -eq $null || $Group.meta.version[0] -eq $null) {
            throw "the meta.version[0] must be specified"
        }
        $path = "/authorize/identity/Group/$($Group.id)/`$remove"
        $response = (Invoke-ApiRequest -AdditionalHeaders @{"If-Match" = $Group.meta.version[0] } -Version 1 -Path $path -Method Post -Body $body -ValidStatusCodes @(200))
    
        # update the group version
        $group.meta.version = $response.meta.version
        
        Write-Output $response
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}