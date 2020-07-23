<#
    .SYNOPSIS
    Returns details of the resource owner associated with the supplied access token

    .DESCRIPTION
    Returns a PSObject of claims about a user associated with the supplied access token.
    The claims returned are ones approved by the user when the access tokens were granted.
    For example, in an authorization code grant flow, the client would have to request the
    scope's email and profile. The user would be prompted at one point to grant consent for
    that information. Only the granted claims are returned to the client. The "sub" claim is
    always returned. For any other claim, if it is either 1) requested but not available, or
    2) not requested, then the entire field will not be returned in the response.
    This implementation is based on the OpenID Connect specification: .

    .INPUTS
    A token

    .OUTPUTS
    A UserInfo PSObject

    .PARAMETER Token
    A token to evaluate. If not supplied then the current user token is used.

    .EXAMPLE
    $userinfo = Get-UserInfo

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api-v2#/User%20Identity/get_authorize_identity_User

    .NOTES
    GET: /authorize/oauth2/userinfo v2
#>
# https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/oauth2-api-v2#/OpenID%20Connect%20UserInfo/userInfoUsingGET
function Get-UserInfo {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [String]$Token
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        if (-not $PSBoundParameters.ContainsKey('Token')) {
            $Token = Get-Token
        }
        Write-Output (Invoke-ApiRequest -Path "/authorize/oauth2/userinfo" -Version 2 -Base (Get-Config).IamUrl -Method "Get" -Authorization "Bearer $($Token)")
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}