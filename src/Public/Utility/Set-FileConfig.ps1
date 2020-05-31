<#
    .SYNOPSIS
    Sets the HSDP-IAM powershell module configuration from a CliXml configuration file

    .DESCRIPTION
    This module stores configuration in a script level varaible to accessing configuration
    across multiple cmdlets easier.

    This cmdlet reads the configuration from a CliXML file into the module configuration.

    .PARAMETER Path
    The path to the configuration xml file. Defaults to "./Config.xml"

    .EXAMPLE
    Set-FileConfig

    .NOTES
    CliXml does not encrypt PSCredential on Mac or *nix
#>
function Set-FileConfig  {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    [OutputType([hashtable])]
    param(
        [ValidateNotNullOrEmpty()]
        [String]$Path = "./Config.xml",

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
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            Set-Config (Import-CliXml -Path $Path)
            $config = Get-Config

            $headers = Get-Headers -IamUrl $config.IamUrl -Credentials $config.Credentials -ClientCredentials $config.ClientCredentials
            Set-Variable -Name _headers -Scope Script -Value $headers
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}