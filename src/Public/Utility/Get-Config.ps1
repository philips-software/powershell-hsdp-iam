<#
    .SYNOPSIS
    Access to the HSDP-IAM powershell module configuration

    .DESCRIPTION
    This module stores configuration in a script level varaible to accessing configuration
    across multiple cmdlets easier.

    This cmdlet returns the HSDP-IAM powershell module configuration hastable

    .EXAMPLE
    $config = Get-Config
#>
function Get-Config  {

    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Get-Variable -Name __config -Scope Script -ValueOnly
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}