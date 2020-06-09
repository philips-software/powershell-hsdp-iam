<#
    .SYNOPSIS
    Removes an client

    .DESCRIPTION
    Deletes a client. This operation is only allowed when no related Client versions exist.

    .INPUTS
    The client resource object

    .OUTPUTS
    None

    .PARAMETER Client
    The client object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/client-api#/Client/delete_authorize_identity_Client__id_

    .NOTES
    DELETE: ​/authorize​/identity​/Client​/{id} v1
#>
function Remove-Client {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Client,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            Invoke-ApiRequest -Path "​/authorize​/identity​/Client​/$($Client.Id)" -Version 1 -Method Delete -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}