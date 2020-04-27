<#
    .SYNOPSIS
    Returns the metadata associated with a token

    .DESCRIPTION
    Returns the metadata associated with a token. Valid client credentials are required to call this API and the client must have been 
    granted the scope: auth_iam_introspect. This client scoped token can return user,client, service or device details based on the type
    of the token. Additionally, if the client requires either managing org or permission information, they must be granted an additional
    scope of: auth_iam_organization.
    
    .OUTPUTS    
    Returns an IntrospectResponse as a PSObject

    .PARAMETER Token
    An optional token to use to evaulate. If not supplied then the current configured user's bearer token will be used.

    .EXAMPLE
    $introspect = Get-Introspect

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/oauth2-api-v3#/OAuth%202.0%20Token%20Introspection/introspectUsingPOST

    .NOTES
    POST: /authorize/oauth2/introspect v3
#>
function Get-Introspect {

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
        if (-not $Token) {
            $Token = Get-Token
        }
        $config = Get-Variable -Name _Config -Scope Script -ValueOnly
        $authForToken = "Basic $(Get-Variable -Name _authForToken -Scope Script -ValueOnly)"
        Write-Output (Invoke-ApiRequest -Path "/authorize/oauth2/introspect" -Version 3 -Authorization $authForToken -Method Post -Base $config.IamUrl -ContentType "application/x-www-form-urlencoded" -Body "token=$($Token)")
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}