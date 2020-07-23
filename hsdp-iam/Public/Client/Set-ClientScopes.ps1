<#
    .SYNOPSIS
    Replaces the client scope

    .DESCRIPTION
    Updates the scope of the client. Users with the role permission "CLIENT.SCOPES" assigned to the manufacturing/producing
    organization role can update the client scopes under the application that is part of the manufacturing/producing organization.
    The CLIENT.SCOPES permission can be assigned to the role of an organization only by an Enterprise administrator.

    .INPUTS
    The client resource object

    .OUTPUTS
    An updated client resource object

    .PARAMETER Client
    The client resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/client-api#/Client/put_authorize_identity_Client__id___scopes

    .EXAMPLE
    $myClient = Get-Clients -Name "MyClient"
    $myClient.scopes += "added_scope"
    $myClient = Set-ClientScopes $myClient.scopes

    .NOTES
    PUT: /authorize/identity/Client/{id}/$scopes v1
#>
function Set-ClientScopes {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Client,

        [Parameter(Mandatory = $false, Position = 1)]
        [String[]]$Scopes = @(),

        [Parameter(Mandatory = $false, Position = 2)]
        [String[]]$DefaultScopes = @(),

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
            $Body = @{
                scopes = $Scopes;
                defaultScopes = $DefaultScopes
            }
            Invoke-ApiRequest "/authorize/identity/Client/$($Client.Id)/`$scopes" -Method Put -Body $Body -Version 1 -ValidStatusCodes @(204) | Out-Null
            Write-Output (Get-Clients -Id $Client.Id)
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}