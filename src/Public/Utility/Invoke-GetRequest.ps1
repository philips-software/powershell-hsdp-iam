
<#
    .SYNOPSIS
    Calls a REST Get Web Request

    .DESCRIPTION
    This is utility function to making calling get requests simple

    .PARAMETER Path
    The url path to call (should not include the basehost address)

    .PARAMETER Version
    The version to set in the header. Defaults to "1"

    .PARAMETER ValidStatusCodes
    An array of int codes to consider a success. Defaults to @(200)
#>
function Invoke-GetRequest {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [String]
        $Version = "1",

        [int[]]
        $ValidStatusCodes = @(200)
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-ApiRequest -Path $Path -Method Get -Version $Version -ValidStatusCodes $ValidStatusCodes)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}