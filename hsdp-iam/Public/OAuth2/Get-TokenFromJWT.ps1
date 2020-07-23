<#
    .SYNOPSIS
    Create token from a JWT

    .DESCRIPTION
    Allows clients to request an access token in exchange for a JWT token.
    NOTE: For this grant type, the Authorization header is EXCLUSIVE.
    This grant type is supported only for service identity. For more details, please refer RFC7523 ().

    .OUTPUTS
        Returns a TokenResponse PSObject

    .PARAMETER JWT
    The JWT

    .EXAMPLE
    $tokenResponse =  Get-TokenFromJWT (New-HsdpJWT -Service $service -KeyFile "./myservice.pem")

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/oauth2-api-v2#/OAuth%202.0%20Authorization/getAccessTokenUsingPOST

    .NOTES
    POST: /authorize/oauth2/token v2
#>
function Get-TokenFromJWT {

    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$JWT
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $Headers = @{
            "api-version"   = "1"
            "Content-Type"  = "application/x-www-form-urlencoded"
            "Accept"        = "application/json"
        }

        $Form = @{
            "grant_type"    = "urn:ietf:params:oauth:grant-type:jwt-bearer"
            "assertion"     = $JWT
        }

        $config = Get-Config
        $Uri = "$($config.IamUrl)/authorize/oauth2/token"

        Write-Output (Invoke-RestMethod -Uri $Uri -Method Post -Body $Form -Headers $Headers)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}