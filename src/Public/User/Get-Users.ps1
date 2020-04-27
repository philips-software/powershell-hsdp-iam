<#
    .SYNOPSIS
    Retrieves multiple user ids for either an org or a group

    .DESCRIPTION
    Retrieves multiple users for either an org or a group

    .OUTPUTS
    An array of user ids

    .PARAMETER Org
    The organization PSObject 

    .PARAMETER Group
    The group PSObject

    .EXAMPLE
    $userIds = Get-User "b41b992a-fb96-475e-90dd-ee3234362ca7"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/legacy-api#/User%20Management/get_security_users

    .NOTES
    GET: /security/users v1
#>
function Get-Users {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(        
        [Parameter(Mandatory=$false, ParameterSetName="Org", ValueFromPipeline)]
        [PSObject]$Org,

        [Parameter(Mandatory=$false, ParameterSetName="Group")]
        [PSObject]$Group
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/security/users"

        if ($PSCmdlet.ParameterSetName -eq "Org") {
            $path += "?organizationId=$($Org.id)&pageSize=99999"
        }

        if ($PSCmdlet.ParameterSetName -eq "Group") {
            $path += "?groupID=$($Group._id)&pageSize=99999"
        }

        Write-Output @(((Invoke-GetRequest -Path $path -Version 1 -ValidStatusCodes @(200)).exchange.users) | Select-Object -ExpandProperty userUUID)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}