<#
    .SYNOPSIS
    Creates a new Proposition.

    .DESCRIPTION
    Create a new proposition. A user with PROPOSITION.WRITE permissions assigned to the organization role
    can create the proposition under the organization.

    .INPUTS
    An organization PSObject

    .OUTPUTS
    An Proposition PSObject

    .PARAMETER Org
    An organization PSObject

    .PARAMETER Name
    The proposition name

    .PARAMETER GlobalReferenceId
    A user defined reference identifier

    .PARAMETER Description
    The proposition description

    .EXAMPLE
    $proposition = Add-Proposition -Org $org -Name "My Proposition" -GlobalReferenceId "67fc0db4-ebce-4872-b522-e353d919200d"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/proposition-api#/Proposition/post_authorize_identity_Proposition

    .NOTES
    POST: /authorize/identity/Proposition v1
#>
function Add-Proposition {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 2)]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory = $false, Position = 3)]
        [String]$Description = ""
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $prop = @{
            "organizationId"    = $org.id;
            "name"              = $Name;
            "globalReferenceId" = $GlobalReferenceId;
            "description"       = $Description;
        }
        $headers = (Invoke-ApiRequest -ReturnResponseHeader -Path "/authorize/identity/Proposition" -Version 1 -Method Post -Body $prop -ValidStatusCodes @(201) )

        # The create proposition does not return a response so use the location header to determine the new object id
        $location = ($headers | ConvertFrom-Json -Depth 20).Location[0]
        if ($location -match "([0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12})") {
            Write-Output (Get-Proposition -Id $matches[0])
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}