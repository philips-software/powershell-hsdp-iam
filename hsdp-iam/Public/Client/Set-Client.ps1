<#
    .SYNOPSIS
    Modify an client properties

    .DESCRIPTION
    Updates the client. Users with the role permission "CLIENT.WRITE" assigned to the manufacturing/producing organization
    role can update the client under the application that is part of the manufacturing/producing organization. The entire
    resource data must be passed as request body to update a client. If read-only attributes (such as id, clientId, realms,
    type, name, scopes, defaultScopes, applicationId, meta, disabled) are passed, that will be ignored.

    Important

    If consentImplied field is set to true, the consent screen won't be displayed and integrators MUST assess the privacy
    implication of turning the consent off as the end user may not know what content is being shared. When you customize the
    values of any token lifetime, you MUST engage your product security team and assess the associated security vulnerability
    of a longer validity period.

    .INPUTS
    The client resource object

    .OUTPUTS
    An updated client resource object

    .PARAMETER Client
    The client resource object to update

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/client-api#/Client/put_authorize_identity_Client__id_

    .EXAMPLE
    $myClient = Get-Clients -Name "MyClient"
    $myClient.description = "this is my client"
    $myClient = Set-Client $myClient

    .NOTES
    PUT: /authorize/identity/Client v1
#>
function Set-Client {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
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
            Write-Output @((Invoke-ApiRequest "/authorize/identity/Client/$($Client.Id)" -Method Put -Body $Client -Version 1 -ValidStatusCodes @(200)))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}