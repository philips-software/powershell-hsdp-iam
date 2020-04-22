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

    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [ValidateNotNullOrEmpty()]
        [psobject]$config
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        
        Set-Variable -Name _Config -Scope Script -Value $config
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}