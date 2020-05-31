<#
    .SYNOPSIS
    Validates user identifiers (either id or name)

    .DESCRIPTION
    Validates that all the user identifiers are valid

    .INPUTS
    An array of either usernames or unique identifiers

    .OUTPUTS
    An array of invalid user ids

    .PARAMETER Ids
    The array of user identifiers to test

    .EXAMPLE
    $invalidUserIds = Test-UserIds @("user1", "user2")

    .EXAMPLE
    $invalidUserIds = Test-UserIds @("92d6dd54-ceb3-4689-8833-d8577d4cd8fb")

#>
function Test-UserIds  {

    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Ids
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        
        [string[]]$invalidUsers = @()
        $Ids | ForEach-Object {            
            if (-not (Get-User -Id $_)) {
                $invalidUsers += $_
                Write-Warning "user '$($_)' is not found"
            }
        }   
        Write-Output $invalidUsers     
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}