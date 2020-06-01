Install-Module PowerShell-JWT -Force

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

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [PSObject]$Service,

        [Parameter(Mandatory = $true, Position = 1)]
        [PSObject]$KeyFile,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            $config = Get-Variable -Name _Config -Scope Script -ValueOnly

            $exp = [int](Get-Date -UFormat %s) + 5400
            $payloadClaims = @{
                "aud" = @("$($config.IamUrl)/oauth2/access_token")
                "sub" = $Service.serviceId
            }

            $rsaPrivateKey = Get-Content $KeyFile -AsByteStream

            Write-Output (New-JWT -Algorithm 'RS256' -Issuer $Service.serviceId -ExpiryTimestamp $exp -PayloadClaims $payloadClaims -SecretKey $rsaPrivateKey)
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}