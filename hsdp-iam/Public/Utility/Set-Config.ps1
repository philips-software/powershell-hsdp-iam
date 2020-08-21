<#
    .SYNOPSIS
    Sets the HSDP-IAM powershell module configuration

    .DESCRIPTION
    This module stores configuration in a script level varaible to accessing configuration
    across multiple cmdlets easier.

    This cmdlet sets the HSDP-IAM powershell module configuration hashtable.

    .EXAMPLE
    Set-Config $config
#>
function Set-Config  {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Config,

        [Parameter()]
        [Switch]
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
            $ConfirmPreference = 'High'
            Set-Variable -Name __config -Scope Script -Value $config
            # Clear the cached values so future requests re-authenticate
            if (Get-Variable -Scope Script -ErrorAction Ignore -Name __authorization_header_value) {
                Remove-Variable -Name __authorization_header_value -Scope script
            }
            if (Get-Variable -Scope Script -ErrorAction Ignore -Name __access_token_expires_at) {
                Remove-Variable -Name __access_token_expires_at -Scope script
            }
            if (Get-Variable -Scope Script -ErrorAction Ignore -Name __auth) {
                Remove-Variable -Name __auth -Scope script
            }
            Get-AuthorizationHeader | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}