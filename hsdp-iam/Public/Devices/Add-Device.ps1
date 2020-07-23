<#
    .SYNOPSIS
    Create a new device

    .DESCRIPTION
    Create a new Device. A user with DEVICE.WRITE permission can create devices under the organization.

    .INPUTS
    Accepts a Organization resource object

    .OUTPUTS
    A new device resource object

    .PARAMETER Org
    The organization to which this Device is part

    .PARAMETER App
    An application resource object

    .PARAMETER LoginId
    The login ID used during authentication flows

    .PARAMETER ExternalId
    An external id

    .PARAMETER Password
    Device credentials used during authentication flows. Note that this value will not be returned during queries.

    .PARAMETER GlobalReferenceId
    Reference identifier defined by the provisioning user. This reference identifier will be carried over to
    identify the provisioned resource across deployment instances (dev, staging, production)

    .PARAMETER Type
    The type of device

    .PARAMETER RegistrationDate
    The device provisioned date

    .PARAMETER ForTest
    Indicates this device is presently in use for testing purposes

    .PARAMETER Active
    Indicates whether this device is blocked for all platform access

    .PARAMETER DebugUntil
    Indicates the date and time more detailed debug information is requested to continue for this device. Used in consumer care scenarios.

    .PARAMETER Text
    The text description for the device added.

    .EXAMPLE
    $org = Get-Org -Id "66417816-ab4b-4633-bd0b-87e1619f875d"
    $app = Get-App -Id "68f153a4-5b86-48dd-80de-19583cdb2228"
    $addDevice = Add-Device -Org $org -App $app -LoginId "mydevicelogin" -ExternalId "283457293457" -Password "P@ssw0rd1$" -GlobalReferenceId "283457293457"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/device-api#/Device%20Management/post_authorize_identity_Device

    .NOTES
    POST: /authorize/identity/Device v1
#>
function Add-Device {

    [CmdletBinding()]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]$Org,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [PSObject]$App,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateLength(5, 50)]
        [String]$LoginId,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateLength(1, 250)]
        [String]$ExternalId,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateLength(8, 255)]
        [String]$Password,

        [Parameter(Mandatory = $true, Position = 5)]
        [ValidateLength(3, 50)]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidateLength(1, 50)]
        [String]$Type,

        [Parameter(Mandatory = $false, Position = 7)]
        [ValidateLength(1, 50)]
        [String]$RegistrationDate,

        [Parameter(Mandatory = $false, Position = 8)]
        [Bool]$ForTest = $false,

        [Parameter(Mandatory = $false, Position = 9)]
        [Bool]$Active = $true,

        [Parameter(Mandatory = $false, Position = 10)]
        [String]$DebugUntil,

        [Parameter(Mandatory = $false, Position = 11)]
        [ValidateLength(1, 250)]
        [String]$Text
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $Body = @{
            organizationId = $Org.Id;
            applicationId = $App.Id;
            loginId = $LoginId;
            deviceExtId = @{
              system = "urn:philips-healthsuite.com";
              value = $ExternalId;
              type = @{
                code = "ID";
                text = "Device Identification";
              }
            }
            password = $Password;
            globalReferenceId = $GlobalReferenceId;
            forTest = $ForTest
            isActive = $Active
        }
        if ($PSBoundParameters.ContainsKey('Type')) {
            $Body.type = $Type
        }
        if ($PSBoundParameters.ContainsKey('RegistrationDate')) {
            $Body.registrationDate = $RegistrationDate
        }
        if ($PSBoundParameters.ContainsKey('DebugUntil')) {
            $Body.debugUntil = $DebugUntil
        }
        if ($PSBoundParameters.ContainsKey('Text')) {
            $Body.text = $Text
        }

        $headers = (Invoke-ApiRequest -ReturnResponseHeader -Path "/authorize/identity/Device" -Version 1 -Method Post -Body $body -ValidStatusCodes @(201) )

        # The created resource does not return a response so use the location header to determine the new object id
        $location = ($headers | ConvertFrom-Json -Depth 20).Location[0]
        if ($location -match "([0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12})") {
            Write-Output (Get-Devices -Id $matches[0] -Org $org)
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}