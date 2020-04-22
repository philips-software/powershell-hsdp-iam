<#
    .SYNOPSIS
    Create a new Service

    .DESCRIPTION
    Creates a service

    .INPUTS
    An application PSObject

    .OUTPUTS
    The new service PSObject

    .PARAMETER Application
    The application PSObject

    .PARAMETER Name
    Name of the service identity. Invalid Characters:- "[&+'";=?#|( )\[\]<>]"

    .PARAMETER PrivateKeyPath
    The location to write the private key file generated

    .PARAMETER Validity
    How long the service will be valid from the date of creation (in months). The default is 12 months.

    .PARAMETER Description
    Text that describes the service.

    .EXAMPLE
    $service = Add-Service -Application $app -Name "MyApp" -PrivateKeyPath "./myapp.pem"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/service-api#/Create%20Service/post_authorize_identity_Service

    .NOTES
    POST: /authorize/identity/Service v1
#>
function Add-Service {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Application,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$PrivateKeyPath,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [int]$Validity = 12,

        [Parameter(Mandatory = $false, Position = 4)]
        [String]$Description = ""
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $body = @{
            "applicationId"     = $Application.id;
            "name"              = $Name;        
            "description"       = $Description;
            "validity"          = $Validity;
        }
        
        $service = (Invoke-ApiRequest -Path "/authorize/identity/Service" -Version 1 -Method Post -Body $body -ValidStatusCodes @(201) )

        $key = $service.privateKey
        $key = $key -replace "-----BEGIN RSA PRIVATE KEY-----", "-----BEGIN RSA PRIVATE KEY-----`n"
        $key = $key -replace "-----END RSA PRIVATE KEY-----", "`n-----END RSA PRIVATE KEY-----`n"

        Set-Content -Path $PrivateKeyPath -Value $key
        
        Write-Output $service
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}