<#
    .SYNOPSIS
    Creates the authorization headers required for all IAM/IDM requests

    .DESCRIPTION
    This API returns a header that will contain the OAuth2.0 access token and an optional refresh token

    .OUTPUTS
    Returns a hashtable containing the headers and values

    .PARAMETER IamUrl
    The HSDP IAM base user. If not supplied then the current configured IAM url will be used.

    .PARAMETER Credentials
    A PSCredential object containing the HSDP credentials. If not supplied then the current configured Credentials will be used.

    .PARAMETER ClientCredentials
    A PSCredential object containing the HSDP  ClientId and Secret. If not supplied then the current configured ClientCredentials will be used.

    .EXAMPLE
    $header = Get-Header

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/oauth2-api-v2#/OAuth%202.0%20Authorization/getAccessTokenUsingPOST

    .NOTES
    POST: /authorize/oauth2/token v2
#>
function Get-Headers {

    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [string]$IamUrl = $null,

        [Parameter(Position = 1, Mandatory = $false)]
        [PSCredential]$Credentials = $null,

        [Parameter(Position = 2, Mandatory = $false)]
        [PSCredential]$ClientCredentials = $null
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $authForToken = $null
        if ($ClientCredentials -eq $null) {
            $config = Get-Config
            $authForToken = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($config.ClientCredentials.GetNetworkCredential().username):$($config.ClientCredentials.GetNetworkCredential().password)"))
        }
        else {
            $authForToken = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ClientCredentials.GetNetworkCredential().username):$($ClientCredentials.GetNetworkCredential().password)"))
        }

        $Headers = @{
            "api-version"   = "2"
            "Content-Type"  = "application/x-www-form-urlencoded; charset=UTF-8"
            "Accept"        = "application/json"
            "Authorization" = "Basic $($authForToken)"
        }

        $Form = $null
        if ($Credentials -eq $null) {
            $config = Get-Config
            $Form = @{
                "grant_type" = "password"
                "username"   = $config.Credentials.GetNetworkCredential().username
                "password"   = $config.Credentials.GetNetworkCredential().password
                "scope"      = "profile email READ_WRITE"
            }
        }
        else {
            $Form = @{
                "grant_type" = "password"
                "username"   = $Credentials.GetNetworkCredential().username
                "password"   = $Credentials.GetNetworkCredential().password
                "scope"      = "profile email READ_WRITE"
            }
        }

        $Uri = $null
        if (-not $IamUrl) {
            $Uri = "$($config.IamUrl)/authorize/oauth2/token"
        }
        else {
            $Uri = "$($IamUrl)/authorize/oauth2/token"
        }

        $auth = Invoke-RestMethod -Uri $Uri -Method Post -Body $Form -Headers $Headers
        Write-Debug ($auth | ConvertTo-Json)

        Set-Variable -Name _token -Scope Script -Value $auth.access_token
        Set-Variable -Name _authForToken -Scope Script -Value $authForToken

        Write-Output @{
            "Connection"    = "keep-alive"
            "api-version"   = "2"
            "Authorization" = "Bearer $($auth.access_token)"
            "Accept"        = "application/json"
            "Content-Type"  = "application/json"
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
