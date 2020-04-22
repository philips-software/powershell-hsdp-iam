<#
    .SYNOPSIS
    Access to the current HSDP-IAM modules token

    .DESCRIPTION
    This module stores configuration in a script level varaible to accessing configuration
    across multiple cmdlets easier. 

    This cmdlet returns the HSDP-IAM powershell module session token.

    .EXAMPLE
    $token = Get-Token
#>
function Get-Token {

    [CmdletBinding()]
    [OutputType([string])]
    param()
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        (Get-Variable -Name _token -Scope Script).Value
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}