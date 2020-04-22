<#
    .SYNOPSIS
    Validates user identifiers

    .DESCRIPTION
    Validates that all user identifiers are valid

    .INPUTS
    An array of either usernames or unique identifiers

    .OUTPUTS
    A OperationOutcome PSObject

    .EXAMPLE
    Test-UserIds @("user1", "user2")
#>
function Test-UserIds  {

    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [array]$userIds
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        
        $valid = $true        
        $userIds | ForEach-Object {
            $user = Get-User $_
            if ($null -eq $user) {
                $valid = $false
                Write-Warning "user '$($_)' is not a valid username"
            }
        }        
        return $valid
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}