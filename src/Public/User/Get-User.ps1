<#
    .SYNOPSIS
    Retrieves a single user

    .DESCRIPTION
    Retrieves a single user object

    .INPUTS
    A user identifier (either username or unique identifier)

    .OUTPUTS
    A user PSObject

    .PARAMETER Id
    A user identifier

    .PARAMETER ProfileType
    A profile type of either "membership","accountStatus","passwordStatus", "consentedApps", "all"
    defaults to "all"

    .EXAMPLE
    $user = Get-User "b41b992a-fb96-475e-90dd-ee3234362ca7"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api-v2#/User%20Identity/get_authorize_identity_User

    .NOTES
    GET: /authorize/identity/User v2
#>
function Get-User {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(        
        [Parameter(Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$Id,
        
        [ValidateSet("membership","accountStatus","passwordStatus", "consentedApps", "all")]
        [String]$ProfileType = "all"
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output @((Invoke-GetRequest "/authorize/identity/User?userId=$($Id)&profileType=$($profileType)" -Version 2 -ValidStatusCodes @(200,400,401,403,406,500)).entry[0])
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}