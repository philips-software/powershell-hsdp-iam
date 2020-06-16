<#
    .SYNOPSIS
    Retrieve saved Kba challenges/questions for a user

    .DESCRIPTION
    Retrieves saved Kba questions for a user based on login id. A private OAuth2.0 client that passes basic
    authorization header will be able to execute this API.

    .INPUTS
    A user resource object

    .OUTPUTS
    A hashtable of challenge/questions for the user

    .PARAMETER User
    The user resource object

    .EXAMPLE
    Get-User "b41b992a-fb96-475e-90dd-ee3234362ca7" | Get-UserKba | ConvertTo-Json

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api#/User%20Management/get_authorize_identity_User__kba

    .NOTES
    GET: /authorize/identity/User/$kba
#>
function Get-UserKba {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$User
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $encoded = [System.Web.HTTPUtility]::UrlEncode($User.loginId)
        $response =  @(Invoke-GetRequest "/authorize/identity/User/`$kba?loginId=$($encoded)" -Version 1 -ValidStatusCodes @(200))
        $hashtable = @{}
        $response.challenges | ForEach-Object {
            $hash = $_
            $hash.Keys | ForEach-Object {
                $hashtable.Add($_, $hash[$_])
            }
        }
        Write-Output $hashtable
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}