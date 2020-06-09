<#
    .SYNOPSIS
    Prompts user for HSDP-IAM module configuration

    .DESCRIPTION
    Collects module configuration from the Host and returns in the form of a PSObject

    .EXAMPLE
    Read-Config
#>

function Read-Config {

    [CmdletBinding()]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification='needed to collect')]
    param()

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IamUrl = Read-Host -Prompt "HSDP IAM URL (example: https://iam-integration.us-east.philips-healthsuite.com)"
        $IdmUrl = Read-Host -Prompt "HSDP IDM URL (example: https://idm-integration.us-east.philips-healthsuite.com)"

        Write-Host "===== HSDP Username and Password (org admin account)"
        $Credentials = Get-Credential

        Write-Host "===== HSDP App Shared Key and Secret (as provied by during onboarding)"
        $AppCredentials = Get-Credential

        Write-Host "===== HSDP OAuth2 ClientId and Secret (referenced as Client Name/Password in the SSUI)"
        $ClientCredentials = Get-Credential

        Write-Host "===== OAuth2 Client Scopes"
        $Scopes = Read-Host -Prompt "Scopes: (example: profile email read_write):"

        Write-Output (New-Object PSObject -Property @{
            Credentials          = $Credentials
            AppCredentials       = $AppCredentials
            ClientCredentials    = $ClientCredentials
            Scopes               = $Scopes.Split(" ")
            IamUrl               = $IamUrl
            IdmUrl               = $IdmUrl
        })
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}




