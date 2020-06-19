<#
    .SYNOPSIS
    Add or Remove Service Scopes

    .DESCRIPTION
    Add or remove service scopes. This operation is only allowed for users with the SERVICE.SCOPE permission. A scope can be added
    either as a default or current scope. Default scopes need not be explicitly requested while getting the access token, but current
    scope must be specified in the token request if the scope is needed for the service.

    .INPUTS
    Accepts the service resource object

    .OUTPUTS
    Nothing

    .EXAMPLE

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/service-api#/Update%20Service%20Scope/put_authorize_identity_Service__id___scopes

    .NOTES
    POST: /authorize/identity/Service/{id}/$scopes v1
#>
function Set-AppServiceScope {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]
        $AppService,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet("add", "remove")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Action,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Scopes = @(),

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $DefaultScopes = @(),

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
            $body = @{
                action = $Action;
                scopes = $Scopes;
                defaultScopes = $DefaultScopes;
            }
            $path = "/authorize/identity/Service/$($AppService.Id)/`$scopes"
            Invoke-ApiRequest -Path $path -Version 1 -Method Put -Body $body -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}