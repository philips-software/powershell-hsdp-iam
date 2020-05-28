<#
    .SYNOPSIS
    Retrieves user ids by specified page and size

    .DESCRIPTION
    Retrieves multiple users for either an org or a group

    .INPUTS
    The context of org or group and the page and size

    .OUTPUTS
    An array of user ids

    .PARAMETER Org
    The organization PSObject. Use either this parameter or the Group parameter but not both.

    .PARAMETER Group
    The group PSObject. Use either this parameter or the Org parameter but not both.

    .PARAMETER Page
    The page number to retrieve. Defaults to 1

    .PARAMETER Size
    The the number of records in a page. Defaults to 100 
    
    .EXAMPLE
    $org = Get-Org "10cd23a9-f111-4fe4-9eec-716b05361565"
    $tenUsers = Get-UsersByPage -Org org -Page 1 -Size 10

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/legacy-api#/User%20Management/get_security_users

    .NOTES
    GET: /security/users v1
#>
function Get-UsersByPage {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(        
        [Parameter(Mandatory = $false, ParameterSetName = "Org", ValueFromPipeline)]
        [PSObject]$Org,

        [Parameter(Mandatory = $false, ParameterSetName = "Group")]
        [PSObject]$Group,

        [Parameter(Mandatory = $false)]
        [int]$Page = 1, 

        [Parameter(Mandatory = $false)]
        [int]$Size = 100
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        $path = "/security/users"

        if ($PSCmdlet.ParameterSetName -eq "Org") {
            $path += "?organizationId=$($Org.id)"
        }
        elseif ($PSCmdlet.ParameterSetName -eq "Group") {
            $path += "?groupID=$($Group._id)"
        }

        $path += "&pageSize=$($Size)&pageNumber=$($Page)"
        Write-Output (Invoke-GetRequest -Path $path -Version 1 -ValidStatusCodes @(200))
    }    

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }           
}