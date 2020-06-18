<#
    .SYNOPSIS
    Creates the authorization headers required for all IAM/IDM requests

    .DESCRIPTION
    This API returns a header that will contain the OAuth2.0 access token and an optional refresh token

    .OUTPUTS
    Returns a string containing the value to use for the header "Authorization"

    .PARAMETER IamUrl
    The HSDP IAM base user. If not supplied then the current configured IAM url will be used.

    .PARAMETER Credentials
    A PSCredential object containing the HSDP credentials. If not supplied then the current configured Credentials will be used.

    .PARAMETER ClientCredentials
    A PSCredential object containing the HSDP  ClientId and Secret. If not supplied then the current configured ClientCredentials will be used.

    .EXAMPLE
    $AuthHeader = Get-AuthorizationHeader

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/oauth2-api-v2#/OAuth%202.0%20Authorization/getAccessTokenUsingPOST

    .NOTES
    POST: /authorize/oauth2/token v2
#>
function Get-AuthorizationHeader {

    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [string]$IamUrl = $null,

        [Parameter(Position = 1, Mandatory = $false)]
        [PSCredential]$Credentials = $null,

        [Parameter(Position = 2, Mandatory = $false)]
        [PSCredential]$ClientCredentials = $null,

        [Parameter(Position = 3, Mandatory = $false)]
        [String[]]$Scopes = @("profile","email","read_write"),

        [Parameter(Position = 4, Mandatory = $false)]
        [Int]$ExpireSlewSeconds = 30
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $config = Get-Config

        # build uri
        $Uri = &{
            $UriBase = "/authorize/oauth2/token"
            if ($PSBoundParameters.ContainsKey('IamUrl')) {
                "$($IamUrl)$($UriBase)"
            } else {
                "$($config.IamUrl)$($UriBase)"
            }
        }

        $useScopes = &{
            if ($PSBoundParameters.ContainsKey('Scopes')) {
                $Scopes
            } else {
                $config.Scopes -Join " "
            }
        }

        $newHeader = $false
        $Body = $null

        # Use script level variable as a cache
        if (-not ($null -eq (Get-Variable -Scope Script -ErrorAction Ignore -Name __authorization_header_value -ValueOnly))) {
            # check if expired
            $now = Get-Date
            if ($now -gt $script:__access_token_expires_at) {
                Write-Debug "access token has expired"
                # use refresh token to get a new access token
                $Body = @{
                        "grant_type"    = "refresh_token";
                        "refresh_token" = $script:__auth.refresh_token;
                        "scope"         = $useScopes
                }
                $newHeader = $true
            } else {
                Write-Debug "access token still valid - using stored value"
            }
        } else {
            Write-Debug "new access token"
            # Generate new headers for auth using credentials
            $script:__authForToken = &{
                $username = $null
                $password = $null
                if ($ClientCredentials) {
                    $username = $ClientCredentials.GetNetworkCredential().username
                    $password = $ClientCredentials.GetNetworkCredential().password
                } else {
                    $username = $config.ClientCredentials.GetNetworkCredential().username
                    $password = $config.ClientCredentials.GetNetworkCredential().password
                }
                [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($username):$($password)"))
            }
            # Create a body for the request
            $Body = &{
                $username = $null
                $password = $null
                if ($Credentials) {
                    $username = $Credentials.GetNetworkCredential().username
                    $password = $Credentials.GetNetworkCredential().password
                } else {
                    $username = $config.Credentials.GetNetworkCredential().username
                    $password = $config.Credentials.GetNetworkCredential().password

                }
                @{
                    "grant_type" = "password"
                    "username"   = $username
                    "password"   = $password
                    "scope"      = $useScopes
                }
            }
            $newHeader = $true
        }

        if ($newHeader) {
            $RequestHeaders = @{
                "api-version"   = "2"
                "Content-Type"  = "application/x-www-form-urlencoded; charset=UTF-8"
                "Accept"        = "application/json"
                "Authorization" = "Basic $($script:__authForToken)"
            }
            Write-Debug "Request Uri: $($Uri)"
            Write-Debug "Request Headers: $($RequestHeaders | ConvertTo-Json)"
            Write-Debug "Request Body: $($Body | ConvertTo-Json)"
            $script:__auth = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -Headers $RequestHeaders

            Write-Debug "Response: $($script:__auth | ConvertTo-Json)"

            # Set the headers to script level
            $script:__authorization_header_value = "Bearer $($script:__auth.access_token)"

            # set a time that the access token expires
            $script:__access_token_expires_at = (Get-Date).AddSeconds($script:__auth.expires_in - $ExpireSlewSeconds)
            Write-Debug "new access token expires at '$($script:__access_token_expires_at)'"
        }
        Write-Output $script:__authorization_header_value
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}