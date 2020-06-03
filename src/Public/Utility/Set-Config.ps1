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
    [OutputType([HashTable])]
    param(
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
            Set-Variable -Name _Config -Scope Script -Value $config
            $headers = Get-Headers -IamUrl $config.IamUrl -Credentials $config.Credentials -ClientCredentials $config.ClientCredentials
            Set-Variable -Name _headers -Scope Script -Value $headers
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}