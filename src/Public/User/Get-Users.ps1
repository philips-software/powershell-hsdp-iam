<#
    .SYNOPSIS
    Retrieves multiple user ids for either an org or a group

    .DESCRIPTION
    Retrieves multiple users for either an org or a group

    .INPUTS
    The organiation or group resource object to retrieve users

    .OUTPUTS
    An array of user ids

    .PARAMETER Org
    The organization resource object. Use either this parameter or the Group parameter but not both.

    .PARAMETER Group
    The group resource object. Use either this parameter or the Org parameter but not both.

    .EXAMPLE
    $org = Get-Org "e69d1807-6376-4f03-be84-8373acd27e24"
    $userIds = Get-Users -Org org

    .EXAMPLE
    $org = $org = Get-Org "e69d1807-6376-4f03-be84-8373acd27e24"
    $group = $org | Get-Groups | select -First
    $userIds = Get-Users -Group $group

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/legacy-api#/User%20Management/get_security_users

    .NOTES
    GET: /security/users v1
#>
function Get-Users {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline)]
        [PSObject]$Org,

        [Parameter(Mandatory=$false)]
        [PSObject]$Group
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $p = @{ Page = 1; Size = 100}
        $p.Org = $Org
        if ($Group) {
            $p.Group = $Group
        }
        do {
            Write-Verbose "Page # $($p.Page)"
            $response = (Get-UsersByPage @p)
            Write-Output ($response.exchange.users | Select-Object -ExpandProperty userUUID)
            $p.Page += 1
        } while (($response.exchange.nextPageExists -eq "true"))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}