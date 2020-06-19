<#
    .SYNOPSIS
    Retrieves a page of device(s) based on a set of parameters.

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
    Retrieve devices for this group resource

    .PARAMETER Page
    The page number to retrieve

    .PARAMETER Size
    The number of resources on a page

    .EXAMPLE
    $devices = Get-DevicesByPage -Org $org

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/device-api#/Device%20Management/get_authorize_identity_Device

    .NOTES
    GET: /authorize/identity/Device v1
#>
function Get-DevicesByPage {

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
        [Bool]$forTest,

        [Parameter(Mandatory = $false, Position = 8)]
        [Bool]$isActive,

        [Parameter(Mandatory = $false, Position = 9)]
        [String]$Type,

        [Parameter(Mandatory = $false, Position = 10)]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory = $false, Position = 11)]
        [PSObject]$Group,

        [Parameter(Mandatory=$false, Position = 12)]
        [int]$Page = 1,

        [Parameter(Mandatory=$false, Position = 13)]
        [int]$Size = 100
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/authorize/identity/Device?"
        $add = "organizationId=$([System.Web.HTTPUtility]::UrlEncode($Org.Id))"

        if ($PSBoundParameters.ContainsKey('Id')) {
            if ($add.length) { $add += "&" }
            $add += "_id=$([System.Web.HTTPUtility]::UrlEncode($Id))"
        }
        if ($PSBoundParameters.ContainsKey('App')) {
            if ($add.length) { $add += "&" }
            $add += "applicationId=$([System.Web.HTTPUtility]::UrlEncode($App.Id))"
        }
        if ($PSBoundParameters.ContainsKey('DeviceExtId')) {
            if ($add.length) { $add += "&" }
            $add += "deviceExtId.value=$([System.Web.HTTPUtility]::UrlEncode($DeviceExtId))"
        }
        if ($PSBoundParameters.ContainsKey('DeviceExtType')) {
            if ($add.length) { $add += "&" }
            $add += "deviceExtId.type=$([System.Web.HTTPUtility]::UrlEncode($DeviceExtType))"
        }
        if ($PSBoundParameters.ContainsKey('DeviceExtSystem')) {
            if ($add.length) { $add += "&" }
            $add += "deviceExtId.system=$([System.Web.HTTPUtility]::UrlEncode($DeviceExtSystem))"
        }
        if ($PSBoundParameters.ContainsKey('LoginId')) {
            if ($add.length) { $add += "&" }
            $add += "loginId=$([System.Web.HTTPUtility]::UrlEncode($LoginId))"
        }
        if ($PSBoundParameters.ContainsKey('ForTest')) {
            if ($add.length) { $add += "&" }
            $add += "forTest=$($ForTest)"
        }
        if ($PSBoundParameters.ContainsKey('IsActive')) {
            if ($add.length) { $add += "&" }
            $add += "isActive=$($IsActive)"
        }
        if ($PSBoundParameters.ContainsKey('Type')) {
            if ($add.length) { $add += "&" }
            $add += "type=$([System.Web.HTTPUtility]::UrlEncode($Type))"
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            if ($add.length) { $add += "&" }
            $add += "globalReferenceId=$([System.Web.HTTPUtility]::UrlEncode($GlobalReferenceId))"
        }
        if ($PSBoundParameters.ContainsKey('Group')) {
            if ($add.length) { $add += "&" }
            $add += "groupId=$([System.Web.HTTPUtility]::UrlEncode($Group.Id))"
        }
        if ($add.length) { $add += "&" }
        $path += $add + "_count=$($Size)&_page=$($Page)"
        Write-Output (Invoke-GetRequest -Path $path -Version 1 -ValidStatusCodes @(200))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }

}