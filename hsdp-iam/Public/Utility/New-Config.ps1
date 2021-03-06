<#
    .SYNOPSIS
    Creates a new HSDP-IAM module configuration PSObject

    .DESCRIPTION
    Collects all configuration options for the module and returns a new PSObject

    .INPUTS
    All the configuration values to create a configuration object

    .OUTPUTS
    The new configuration object.

    .PARAMETER Prompt
    Should the user be prompted for all values. If no then all the additional parameters must be provided

    .PARAMETER CredentialsUserName
    User name with org administrative role

    .PARAMETER CredentialsPassword
    Password with org administrative role

    .PARAMETER ClientCredentialsUserName
    IAM client key

    .PARAMETER ClientCredentialsPassword
    IAM client secret

    .PARAMETER Scopes
    The scopes to use for the client

    .PARAMETER AppCredentialsUserName
    App shared key

    .PARAMETER AppCredentialsPassword
    App secret

    .PARAMETER IamUrl
    The HSDP IAM URL. Example: https://iam-integration.us-east.philips-healthsuite.com

    .PARAMETER IdmUrl
    The HSDP IDM URL. Example: https://idm-integration.us-east.philips-healthsuite.com

    .PARAMETER Path
    The path to store the configuration xml file. defaults to "./config.xml". If $null is passed then no configuration is written to a file.

    .EXAMPLE
    New-Config
#>
function New-Config {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
    param(
        [Parameter()]
        [Bool]
        $Prompt = $true,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CredentialsUserName,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CredentialsPassword,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AppCredentialsUserName,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AppCredentialsPassword,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ClientCredentialsUserName,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ClientCredentialsPassword,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Scopes = @("profile","email","read_write"),

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $IamUrl,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $IdmUrl,

        [Parameter(Mandatory=$false)]
        [String]
        $Path = "./config.xml",

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
            $config = $null
            if ($Prompt) {
                $config = Read-Config
            } else {
                $config = (New-Object PSObject -Property @{
                    Credentials         = New-Object System.Management.Automation.PSCredential ($CredentialsUserName, (ConvertTo-SecureString -String $CredentialsPassword -AsPlainText -Force))
                    ClientCredentials   = New-Object System.Management.Automation.PSCredential ($ClientCredentialsUserName, (ConvertTo-SecureString -String $ClientCredentialsPassword -AsPlainText -Force))
                    AppCredentials      = New-Object System.Management.Automation.PSCredential ($AppCredentialsUserName, (ConvertTo-SecureString -String $AppCredentialsPassword -AsPlainText -Force))
                    IamUrl              = $IamUrl
                    IdmUrl              = $IdmUrl
                    Scopes              = $Scopes
                })
            }
            if ($Path) {
                $config | Export-Clixml -Path $Path
            }
            Write-Output $config
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
