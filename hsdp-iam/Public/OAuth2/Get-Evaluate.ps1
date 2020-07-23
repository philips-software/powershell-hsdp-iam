<#
    .SYNOPSIS
    Evaluate policies based on the resource access requested.

    .DESCRIPTION
    Evaluates all types of policies that are applicable to the resource(s) requested with respect to the subject specified.

    Before evaluating the policies, the subject token will be validated to make sure the subject is authenticated. Once the validation
    is successful, the subject permissions will be evaluated against the resource policies to see what actions the subject can do on the resource.

    Any client with auth_iam_policy_evaluation scope will be able to do this operation.

    Condition based evaluation
    If evaluation need to be done based on certain circumstances under which the policy must be allowed, environment attribute can be used to achieve that.
    For example, verify if the subject has the requested permission under a specific organization or not. Supported environment condition key
    is - organizationId. Given an organization ID, evaluation will filter the policy decision check with respect to the specified organization.

    Requested permission based evaluation
    A resource can be evaluated with a specific request permission. This allows client to evaluate whether a specific permission is available for the
    subject to access the requested resource. For example, a resource attribute value of
    https://my-service.example.com/patient/Observation?requestedPermission=OBSERVATION.READ means that while evaluating this resource
    check whether the subject has OBSERVATION.READ permission.

    .OUTPUTS
    Returns an EvalResponse as a PSObject

    .PARAMETER Application
    The application resource object to evaluate access

    .PARAMETER Resources
    An array of resource urls to evaulate

    .PARAMETER Token
    An optional token to use to evaulate. If not supplied then the current configured user's bearer token will be used.

    .PARAMETER TokenType
    One of the following token types: "ACCESS_TOKEN","SSO_TOKEN". The default is access.

    .PARAMETER Org
    An optional organization object for condition based evaluation

    .EXAMPLE

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/policy-api-v3#/Policy%20evaluation/post_authorize_policy__evaluate

    .NOTES
    POST: /authorize/policy/$evaluate v3
#>
function Get-Evaluate {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [PSObject]$Application,

        [Parameter(Position = 1, Mandatory = $true)]
        [Array]$Resources,

        [Parameter(Position = 2, Mandatory = $false)]
        [String]$Token = $null,

        [Parameter(Position = 3, Mandatory = $false)]
        [ValidateSet("ACCESS_TOKEN","SSO_TOKEN")]
        [String]$TokenType = "ACCESS_TOKEN",

        [Parameter(Position = 4, Mandatory = $false)]
        [Array]$Org
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # Use the current user token if not specified
        if (-not $Token) {
            $Token = Get-Token
        }

        $body =  @{
            "application" = $Application.id;
            "resources" = $Resources;
            "subject" = @{
              "type"= $TokenType;
              "value" = $Token;
            };
        }

        if ($Org) {
            $body.Add("environment", @{ "organizationId" = $Org._id });
        }

        $config = Get-Config

        $OAuth2ClientId = $config.ClientCredentials.GetNetworkCredential().username
        $OAuth2ClientPassword = $config.ClientCredentials.GetNetworkCredential().password

        $auth = "Basic " + [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($OAuth2ClientId):$($OAuth2ClientPassword)"))
        Write-Output (Invoke-ApiRequest -Path "/authorize/policy/`$evaluate" -Version 3 -Method Post -Base $config.IamUrl -Body $body -ValidStatusCodes @(200) -Authorization $auth)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}