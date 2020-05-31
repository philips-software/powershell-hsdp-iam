<#
    .SYNOPSIS
    Modify an organization resource properties.

    .DESCRIPTION
    Updates an existing organization resource attributes. It is advised to pass the entire resource object
    while performing an update. The readOnly attributes will be ignored even if it is not matching with the
    actual resource. A OAuth2.0 Bearer token of a subject with HSDP_IAM_ORGANIZATION.UPDATE permission is
    required to perform only this operation.

    NOTE: The following readWrite attributes will NOT be allowed to update currently - name, parent.value

    .INPUTS
    The organization PSObject

    .OUTPUTS
    An updated organization PSObject

    .PARAMETER Org
    The organization PSObject

    .PARAMETER Deactivate
    Will deactive the organization if specified

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/put_Organizations__id_

    .EXAMPLE
    $org = Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"
    $org.description = "changed description"
    $updatedOrg = Set-Org $org

    .NOTES
    PUT: /Organizations/{id} v2
#>
function Set-Org {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Switch]
        [Parameter(Mandatory=$false)]
        $Deactivate,

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
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            if ($Deactivate) {
                $TempOrg = @{
                    "schemas"= @("urn:ietf:params:scim:api:messages:philips:hsdp:2.0:StatusOp");
                    "active" = "false";
                    "meta" = @{ "version" = $Org.meta.version; };
                }
                Write-Output @((Invoke-ApiRequest "/authorize/scim/v2/Organizations/$($Org.id)/status" -Method Post -AddIfMatch -Body $TempOrg -Version 2 -ValidStatusCodes @(200)))
            } else {
                Write-Output @((Invoke-ApiRequest "/authorize/scim/v2/Organizations/$($Org.id)" -Method Put -AddIfMatch -Body $Org -Version 2 -ValidStatusCodes @(200)))
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}