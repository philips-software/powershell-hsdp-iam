<#
    .SYNOPSIS
    Returns a requested role definition.

    .DESCRIPTION
    This cmdlet returns all roles matching one of the criteria. Either Org, Group or Name may be specified.

    .OUTPUTS
    An array of role resource objects

    .PARAMETER Org
    An organization resource object to filter the roles

    .PARAMETER Group
    A group resource object to filter the roles

    .PARAMETER Name
    A role name

    .EXAMPLE
    $roles = Get-Roles -Org $Org

    .EXAMPLE
    $roles = Get-Roles -Group $group

    .EXAMPLE
    $roles = Get-Roles -Name "My Role"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/role-api#/Role%20Management/List%20Roles

    .NOTES
    GET: /authorize/identity/Role v1
#>
function Get-Roles {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(ValueFromPipeline, Mandatory=$false, ParameterSetName="Org")]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory=$false, ParameterSetName="Group")]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Group,

        [Parameter(Mandatory=$false, ParameterSetName="Name")]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/authorize/identity/Role"

        # TBD: Support permutations of these options
        if ($PSCmdlet.ParameterSetName -eq "Org") {
            $path += "?organizationId=$($Org.id)"
        }
        if ($PSCmdlet.ParameterSetName -eq "Group") {
            $path += "?groupId=$($Group.id)"
        }
        if ($PSCmdlet.ParameterSetName -eq "Name") {
            $path += "?name=$($Name)"
        }
        Write-Output @((Invoke-GetRequest $path -Version 1).entry)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}