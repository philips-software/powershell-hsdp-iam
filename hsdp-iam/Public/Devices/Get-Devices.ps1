<#
    .SYNOPSIS
    Retrieves device(s) based on a set of parameters.

    .DESCRIPTION
    Retrieves device(s) based on a set of parameters. A user with DEVICE.READ permission can read device information under the user organization.

    .INPUTS
    Accepts an organization resource object

    .OUTPUTS
    An array of device resource objects

    .PARAMETER Org
    The organization resource this device is assigned

    .PARAMETER Id
    The device resource identifier

    .PARAMETER App
    The appplication resource this device is assigned

    .PARAMETER DeviceExtId
    The device external identifer

    .PARAMETER DeviceExtType
    The device external identifer type

    .PARAMETER DeviceExtSystem
    The device external identifer system

    .PARAMETER LoginId
    The login ID used during authentication flows

    .PARAMETER ForTest
    Indicates this device is presently in use for testing purposes

    .PARAMETER IsActive
    Indicates whether this device is blocked for all platform access

    .PARAMETER Type
    The type of device

    .PARAMETER GlobalReferenceId
    Reference identifier defined by the provisioning user. This reference identifier will be carried over to
    identify the provisioned resource across deployment instances (dev, staging, production)

    .PARAMETER Group
    All devices in the specified group resource

    .EXAMPLE
    $devices = Get-Devices -Org $org

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/device-api#/Device%20Management/get_authorize_identity_Device

    .NOTES
    GET: /authorize/identity/Device v1
#>
function Get-Devices {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [PSObject]$Org,

        [Parameter(Mandatory = $false, Position = 1)]
        [PSObject]$Id,

        [Parameter(Mandatory = $false, Position = 2)]
        [PSObject]$App,

        [Parameter(Mandatory = $false, Position = 3)]
        [String]$DeviceExtId,

        [Parameter(Mandatory = $false, Position = 4)]
        [String]$DeviceExtType,

        [Parameter(Mandatory = $false, Position = 5)]
        [String]$DeviceExtSystem,

        [Parameter(Mandatory = $false, Position = 6)]
        [String]$LoginId,

        [Parameter(Mandatory = $false, Position = 7)]
        [Bool]$ForTest,

        [Parameter(Mandatory = $false, Position = 8)]
        [Bool]$IsActive,

        [Parameter(Mandatory = $false, Position = 9)]
        [String]$Type,

        [Parameter(Mandatory = $false, Position = 10)]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory = $false, Position = 11)]
        [PSObject]$Group
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $p = @{ Page = 1; Size = 100}
        if ($PSBoundParameters.ContainsKey('Org')) {
            $p.Org = $Org
        }
        if ($PSBoundParameters.ContainsKey('Id')) {
            $p.Id = $Id
        }
        if ($PSBoundParameters.ContainsKey('App')) {
            $p.App = $App
        }
        if ($PSBoundParameters.ContainsKey('DeviceExtId')) {
            $p.DeviceExtId = $DeviceExtId
        }
        if ($PSBoundParameters.ContainsKey('DeviceExtType')) {
            $p.DeviceExtType = $DeviceExtType
        }
        if ($PSBoundParameters.ContainsKey('DeviceExtSystem')) {
            $p.DeviceExtSystem = $DeviceExtSystem
        }
        if ($PSBoundParameters.ContainsKey('LoginId')) {
            $p.LoginId = $LoginId
        }
        if ($PSBoundParameters.ContainsKey('forTest')) {
            $p.forTest = $forTest
        }
        if ($PSBoundParameters.ContainsKey('isActive')) {
            $p.isActive = $isActive
        }
        if ($PSBoundParameters.ContainsKey('Type')) {
            $p.Type = $Type
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            $p.GlobalReferenceId = $GlobalReferenceId
        }
        if ($PSBoundParameters.ContainsKey('Group')) {
            $p.Group = $Group
        }
        do {
            Write-Verbose "Page # $($p.Page)"
            $response = Get-DevicesByPage @p
            Write-Output $response.entry
            $p.Page += 1
        } while (($response.total -eq $p.Size))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }

}