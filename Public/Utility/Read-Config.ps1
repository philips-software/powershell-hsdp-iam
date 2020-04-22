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
    param()
    
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        

        $IamUrl = Read-Host -Prompt "HSDP IAM URL (example: https://iam-integration.us-east.philips-healthsuite.com)"
        $IdmUrl = Read-Host -Prompt "HSDP IDM URL (example: https://idm-integration.us-east.philips-healthsuite.com)"

        Write-Host "===== HSDP Username and Password ====="
        $Credentials = Get-Credential

        Write-Host "===== HSDP ClientId and Secret ====="
        $ClientCredentials = Get-Credential

        Write-Host "===== HSDP App Shared Key and Secret ====="
        $AppCredentials = Get-Credential

        Write-Host "===== HSDP OAuth2 ClientId and Secret ====="
        $OAuth2Credentials = Get-Credential

        Write-Output (New-Object PSObject -Property @{
            Credentials          = $Credentials
            ClientCredentials    = $ClientCredentials
            AppCredentials       = $AppCredentials
            OAuth2Credentials    = $OAuth2Credentials
            IamUrl               = $IamUrl
            IdmUrl               = $IdmUrl
        })
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }       
}




