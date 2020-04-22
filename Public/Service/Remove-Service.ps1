<#
    .SYNOPSIS
    Deletes a Service

    .DESCRIPTION
    This operation is only allowed when no related Service versions exist. Removes a service identity
    from an organization. The is usually done by a organization administrator.
    Any user with SERVICE.DELETE permission within the organization can also delete a service from an organization.

    .INPUTS
    A service PSObject

    .OUTPUTS
    An OperationOutcome PSObject

    .PARAMETER Service
    A service PSObject

    .EXAMPLE
    Remove-Service $service

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/service-api#/Delete%20Service/delete_authorize_identity_Service__id_

    .NOTES
    DELETE: /authorize/identity/Service v1
#>
function Remove-Service {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Service
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"        
        $response  = (Invoke-ApiRequest -Path "/authorize/identity/Service/$($Service.id)" -Version 1 -Method Delete -ValidStatusCodes @(204))
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}