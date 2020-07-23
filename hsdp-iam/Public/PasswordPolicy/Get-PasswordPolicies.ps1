<#
    .SYNOPSIS
    Retrieve all password policies in an org

    .DESCRIPTION
    Retrieves all registered password policies within an organization. Any user with PASSWORDPOLICY.WRITE or PASSWORDPOLICY.READ permission can list the policy.

    .OUTPUTS
    An array of policy resource objects

    .PARAMETER Org
    The organizational resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/password-api#/Password%20Policy/get_authorize_identity_PasswordPolicy

    .EXAMPLE
    $PasswordPolicies = Get-PasswordPolicies -Org $myOrg

    .NOTES
    GET: /authorize/identity/PasswordPolicy v1
#>
function Get-PasswordPolicies {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline, Position =0)]
        [ValidateNotNull()]
        [PSObject]$Org
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output @((Invoke-GetRequest "/authorize/identity/PasswordPolicy?organizationId=$($Org.Id)" -Version 1 -ValidStatusCodes @(200)).entry)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}