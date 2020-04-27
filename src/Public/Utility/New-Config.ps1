<#
    .SYNOPSIS
    Creates a new HSDP-IAM module configuration PSObject

    .DESCRIPTION
    Collects all configuration options for the module and returns a new PSObject

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

    .PARAMETER AppCredentialsUserName
    App shared key
    
    .PARAMETER AppCredentialsPassword
    App secret

    .PARAMETER OAuth2CredentialsUserName
    OAuth2 Client ID and password 
    
    .PARAMETER OAuth2CredentialsPassword
    OAuth2  password 
    
    .PARAMETER IamUrl
    The HSDP IAM URL. Example: https://iam-integration.us-east.philips-healthsuite.com

    .PARAMETER IdmUrl
    The HSDP IDM URL. Example: https://idm-integration.us-east.philips-healthsuite.com

    .PARAMETER Path
    The path to store the configuration xml file. defaults to "./config.xml"

    .EXAMPLE
    New-Config
#>
function New-Config {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter()]
        [Bool]
        $Prompt = $true,

        [Parameter()]
        [String]
        $CredentialsUserName,

        [Parameter()]
        [String]
        $CredentialsPassword,

        [Parameter()]
        [String]
        $ClientCredentialsUserName,

        [Parameter()]
        [String]
        $ClientCredentialsPassword,

        [Parameter()]
        [String]
        $AppCredentialsUserName,

        [Parameter()]
        [String]
        $AppCredentialsPassword,

        [Parameter()]
        [String]
        $OAuth2CredentialsUserName,

        [Parameter()]
        [String]
        $OAuth2CredentialsPassword,

        [Parameter()]
        [String]
        $IamUrl,

        [Parameter()]
        [String]
        $IdmUrl,

        [Parameter()]
        [String]
        $Path = "./config.xml"
    )
    
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        

        $config = $null
        if ($Prompt) {
            $config = Read-Config
        } else {
            $config = (New-Object PSObject -Property @{
                Credentials         = New-Object System.Management.Automation.PSCredential ($CredentialsUserName, (ConvertTo-SecureString -String $CredentialsPassword -AsPlainText -Force))
                ClientCredentials   = New-Object System.Management.Automation.PSCredential ($ClientCredentialsUserName, (ConvertTo-SecureString -String $ClientCredentialsPassword -AsPlainText -Force))
                AppCredentials      = New-Object System.Management.Automation.PSCredential ($AppCredentialsUserName, (ConvertTo-SecureString -String $AppCredentialsPassword -AsPlainText -Force))
                OAuth2Credentials   = New-Object System.Management.Automation.PSCredential ($OAuth2CredentialsUserName, (ConvertTo-SecureString -String $OAuth2CredentialsPassword -AsPlainText -Force))
                IamUrl              = $IamUrl
                IdmUrl              = $IdmUrl
            })            
        }
        if ($Path) {
            $config | Export-Clixml -Path $Path
        }
        Write-Output $config
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }       
}
