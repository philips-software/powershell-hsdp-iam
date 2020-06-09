<#
    .SYNOPSIS
    Create a new client.

    .DESCRIPTION
    This specification defines a set of REST endpoints that support the provisioning of a client for an application under a proposition.

    .INPUTS
    Accepts a Application resource object

    .OUTPUTS
    A new client resource object

    .PARAMETER Application
    The application resource object to associate the new client

    .PARAMETER ClientId
    A user defined identifier for the client

    .PARAMETER Type
    The type of client. Must be either Public or Confidential

    .PARAMETER Name
    The Name of the client

    .PARAMETER Password
    The password for client access. 1) At least one capital is required. 2) Special characters required. 3) Allowed special characters are:- "-!@#.:_?{$","

    .PARAMETER GlobalReferenceId
    Reference identifier defined by the provisioning user. This reference Identifier will be carried over to identify the provisioned
    resource across deployment instances (dev, staging, production)

    .PARAMETER Description
    Description of the client.

    .PARAMETER RedirectionURIs
    An array of the redirect URIs.

    .PARAMETER ResponseTypes
    An array of the response types

    .PARAMETER ConsentImplied
    When supplied the resource owner will not be asked for consent during authorization flows

    .PARAMETER AccessTokenLifetime
    The Lifetime of the access token in seconds. If not specified, system default life time (1800secs) will be considered.

    .PARAMETER RefreshTokenLifetime
    The Lifetime of the refresh token in seconds. If not specified, system default life time (2592000secs) will be considered.

    .PARAMETER IdTokenLifetime
    Lifetime of the jwt token generated in case openid scope is enabled for the client. If not specified, system default life time (3600 secs) will be considered.

    .EXAMPLE
    $client = Add-Client -Application (Get-Application -Name "MyApplication") -ClientId "MyClient01" -Type "Confidential" -Name "MyClientName01" -Password "P@ssw0rd1" -GlobalReferenceId "2367283762"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/client-api#/Client/post_authorize_identity_Client

    .NOTES
    POST: /authorize/identity/Client v1
#>
function Add-Client {

    [CmdletBinding()]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Application,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(5, 20)]
        [String]$ClientId,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateSet("Public", "Confidential")]
        [String]$Type,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(5, 50)]
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(8, 16)]
        [String]$Password,

        [Parameter(Mandatory = $true, Position = 5)]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidateNotNullOrEmpty()]
        [String]$Description = "",

        [Parameter(Mandatory = $false, Position = 7)]
        [string[]]$RedirectionURIs = @(),

        [Parameter(Mandatory = $false, Position = 8)]
        [string[]]$ResponseTypes = @(),

        [Parameter(Mandatory = $false, Position = 9)]
        [Switch]$ConsentImplied,

        [Parameter(Mandatory = $false, Position = 10)]
        [Int]$AccessTokenLifetime = 1800,

        [Parameter(Mandatory = $false, Position = 11)]
        [Int]$RefreshTokenLifetime = 2592000,

        [Parameter(Mandatory = $false, Position = 12)]
        [Int]$IdTokenLifetime = 604800
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $body = @{
                "clientId"= $ClientId;
                "password"= $Password;
                "type"= $Type;
                "name"= $Name;
                "description"= $Description;
                "redirectionURIs"= $RedirectionURIs;
                "responseTypes"= $ResponseTypes;
                "applicationId"= $Application.Id;
                "globalReferenceId"= $GlobalReferenceId;
                "consentImplied"= $ConsentImplied.ToString()
                "accessTokenLifetime"= $AccessTokenLifetime;
                "refreshTokenLifetime"= $RefreshTokenLifetime;
                "idTokenLifetime"= $IdTokenLifetime;
        }
        $headers = (Invoke-ApiRequest -ReturnResponseHeader -Path "/authorize/identity/Client" -Version 1 -Method Post -Body $body -ValidStatusCodes @(201))

        # The created application does not return a response so use the location header to determine the new object id
        $location = ($headers | ConvertFrom-Json -Depth 20).Location[0]
        if ($location -match "([0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12})") {
            Write-Output (Get-Clients -Id $matches[0])
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}