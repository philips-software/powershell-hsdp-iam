<#
    .SYNOPSIS
    Retrieve a single password policy

    .DESCRIPTION
    Retrieves a password policy based on password policy id. Any user with PASSWORDPOLICY.READ OR PASSWORDPOLICY.WRITE permission can get the policy.

    .OUTPUTS
    An policy resource object

    .PARAMETER Id
    The id of the password policy

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/password-api#/Password%20Policy/get_authorize_identity_PasswordPolicy

    .EXAMPLE
    $PasswordPolicy = Get-PasswordPolicy -Id "7b8966a2-b5e2-4c09-bab0-0b9a9d2ccae4"

    .NOTES
    GET: /authorize/identity/PasswordPolicy/{id} v1
#>
function Get-PasswordPolicy {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline, Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/authorize/identity/PasswordPolicy/$($Id)" -Version 1 -ValidStatusCodes @(200))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}