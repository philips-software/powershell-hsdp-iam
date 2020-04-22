Install-Module powershell-jwt
<#
    .SYNOPSIS
    Create a JWT for a service

    .DESCRIPTION
    Create a new JWT for a service so that oauth2 tokens maybe generated for the service

    .INPUTS
    A service PSObject

    .OUTPUTS    
    Returns a JWT string

    .PARAMETER Service
    A service PSObject

    .PARAMETER KeyFile
    A previously generated keyfile for the service from the New-Service cmdlet

    .EXAMPLE
    $jwt = New-HsdpJWT -Service $service -KeyFile "myservice.pem"
#>
function New-HsdpJWT {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [PSObject]$Service,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSObject]$KeyFile

    )    

    $config = Get-Variable -Name _Config -Scope Script -ValueOnly
    
    $exp = [int](Get-Date -UFormat %s) + 5400    
    $payloadClaims = @{
        "aud" = @("$($config.IamUrl)/oauth2/access_token")
        "sub" = $Service.serviceId
    }

    $rsaPrivateKey = Get-Content $KeyFile -AsByteStream

    Write-Output (New-JWT -Algorithm 'RS256' -Issuer $Service.serviceId -ExpiryTimestamp $exp -PayloadClaims $payloadClaims -SecretKey $rsaPrivateKey)
    
}