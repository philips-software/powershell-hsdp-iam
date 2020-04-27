<#
    .SYNOPSIS
    Create a new group

    .DESCRIPTION
    Creates a new group within an organization. A user with GROUP.WRITE permission within the organization will be allowed to create a group
    in that organization. If a group with same name already exists in the organization, then the request will fail.

    .INPUTS
    Accepts the managing organization object

    .OUTPUTS
    The new group object

    .PARAMETER Org
    The managing organization that the group will be created 

    .PARAMETER Name
    The name of the group

    .PARAMETER Description
    The description of the group

    .EXAMPLE 
    $group = $org | Add-Group -Name "My Group"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group

    .NOTES
    POST: /authorize/identity/Group v1
#>
function Add-Group {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Position = 2)]
        [String]$Description = ""
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $Group = @{
            "name"                 = $Name;
            "description"          = $Description;
            "managingOrganization" = $Org.id
        }
        $response = (Invoke-ApiRequest -Path "/authorize/identity/Group" -Version 1 -Method Post -Body $Group)
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}