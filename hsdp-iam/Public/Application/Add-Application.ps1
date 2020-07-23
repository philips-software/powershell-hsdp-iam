<#
    .SYNOPSIS
    Create a new application

    .DESCRIPTION
    Creates a new Application. A user with APPLICATION.WRITE permissions assigned to the organization role can create
    applications under the proposition.

    .INPUTS
    Accepts a proposition resource object

    .OUTPUTS
    A new application resource object.

    .PARAMETER Proposition
    The proposition resource object

    .PARAMETER Name
    The name of the application

    .PARAMETER GlobalReferenceId
    A user defined defined UUID to identify the application

    .PARAMETER Name
    The name of the application

    .PARAMETER Description
    The description of the application

    .EXAMPLE
    $app = $proposition | Add-Application -Name "My Application" -GlobalReferenceId "38145648-e41b-4f79-9b54-524e85349b0e"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/application-api#/Application/post_authorize_identity_Application

    .NOTES
    POST: /authorize/identity/Application v1
#>
function Add-Application {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Proposition,

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
        $body = @{
            "propositionId"     = $Proposition.id;
            "name"              = $Name;
            "globalReferenceId" = $GlobalReferenceId;
            "description"       = $Description;
        }
        $headers = (Invoke-ApiRequest -ReturnResponseHeader -Path "/authorize/identity/Application" -Version 1 -Method Post -Body $body -ValidStatusCodes @(201) )

        # The created application does not return a response so use the location header to determine the new object id
        $location = ($headers | ConvertFrom-Json -Depth 20).Location[0]
        if ($location -match "([0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12})") {
            Write-Output (Get-Applications -Id $matches[0])
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}