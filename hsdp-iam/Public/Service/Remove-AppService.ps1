<#
    .SYNOPSIS
    Deletes a app Service

    .DESCRIPTION
    This operation is only allowed when no related Service versions exist. Removes a service identity
    from an organization. The is usually done by a organization administrator.
    Any user with SERVICE.DELETE permission within the organization can also delete a service from an organization.

    .INPUTS
    An app service resource object

    .OUTPUTS
    An OperationOutcome PSObject

    .PARAMETER Service
    An app service resource object

    .EXAMPLE
    Remove-Service $service

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/service-api#/Delete%20Service/delete_authorize_identity_Service__id_

    .NOTES
    DELETE: /authorize/identity/Service v1
#>
function Remove-AppService {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Service,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            Write-Output @(Invoke-ApiRequest -Path "/authorize/identity/Service/$($Service.id)" -Version 1 -Method Delete -ValidStatusCodes @(204))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}