<#
    .SYNOPSIS
    Retrieves Application(s) based on a set of parameters.

    .DESCRIPTION
    Retrieves Application(s) based on a set of parameters in order to either check certain values, or to change (some) values 
    of this resource and PUT the resource back to the API. A user with APPLICATION.READ permissions assigned to the organization
    role can retrieve the application under the proposition. The ID or propositionId parameter is mandatory for application retrieval.

    .INPUTS
    Accepts the application identifier

    .OUTPUTS
    The application object.

    .PARAMETER Id
    The identifier of application

    .EXAMPLE 
    $app = Get-Application -Id "9c186070-2804-45bb-b397-72396651f5db"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/application-api#/Application/get_authorize_identity_Application

    .NOTES
    GET: ​/authorize​/identity​/Application v1
#>
function Get-Application {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [String]$Id
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $response = (Invoke-GetRequest "/authorize/identity/Application?_id=$($Id)" -Version 1 -ValidStatusCodes @(200) )
        Write-Output $response.entry
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}