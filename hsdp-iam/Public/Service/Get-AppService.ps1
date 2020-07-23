<#
    .SYNOPSIS
    Retrieve app services

    .DESCRIPTION
    Retrieves app services based on various query parameters supported.

    .INPUTS
    An app service identifier

    .OUTPUTS
    An app service resource object

    .PARAMETER Id
    A app service identifier

    .PARAMETER Name
    The name of the app service

    .PARAMETER Application
    The application resource object that is paried with the service

    .PARAMETER Org
    The organization resource object that owns the service

    .PARAMETER PrivateKeyPath
    A path to the private key file to re-attach to the service object

    .EXAMPLE
    $service = Get-Service -Id "03b1709d-190e-4da4-a7ab-78dd4dd08f0d"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/service-api#/List%20Service/get_authorize_identity_Service

    .NOTES
    GET: /authorize/identity/Service v1
#>
function Get-AppService {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline, ParameterSetName="Id")]
        [String]$Id,

        [Parameter(Mandatory = $false, ParameterSetName="Name")]
        [String]$Name,

        [Parameter(Mandatory = $false, ParameterSetName="Application")]
        [PSObject]$Application,

        [Parameter(Mandatory = $false, ParameterSetName="Org")]
        [PSObject]$Org,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$PrivateKeyPath = ""
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/authorize/identity/Service"

        # TODO: Support paging
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $path += "?_id=$($Id)&pageSize=99999"
        }

        if ($PSCmdlet.ParameterSetName -eq "Name") {
            $path += "?name=$($Name)&pageSize=99999"
        }

        if ($PSCmdlet.ParameterSetName -eq "Application") {
            $path += "?applicationId=$($Application.id)&pageSize=99999"
        }

        if ($PSCmdlet.ParameterSetName -eq "Org") {
            $path += "?organizationId=$($Org.id)&pageSize=99999"
        }

        $response = (Invoke-GetRequest $path -Version 1 -ValidStatusCodes @(200) )

        # Read the private key file to set on the service if provided
        if ($response.entry -and $PrivateKeyPath) {
            $response.entry.privateKey = (Get-Content -Path $PrivateKeyPath)
        }
        Write-Output $response.entry
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}