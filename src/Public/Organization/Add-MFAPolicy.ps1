<#
    .SYNOPSIS
    Creates a multi-factor authentication policy

    .DESCRIPTION
    Creates a multi-factor authentication (MFA) policy for an organization or user. Only one MFA policy can be created for an organization 
    or user. A OAuth2.0 Bearer token of a subject with HSDP_IAM_MFA_POLICY.CREATE permission is required to perform only this operation.
    Two types of MFA policies are supported - SOFT_OTP based and SERVER_OTP based.

    SOFT_OTP - One-time passcode generated using any mobile authenticator application installed at user's mobile device.

    SERVER_OTP - One-time passcode generated by authentication server which will be sent to the user via email. The email address 
    of the user MUST be configured at the time of user registration to receive an OTP message. If the email address is not configured, 
    the OTP message will NOT be sent to the user.

    An active MFA policy at an organization level will apply to all child organizations underneath the organization. If you want to disable 
    MFA for any child organization(s), create a new MFA policy for the child organization by setting the active flag to false.

    .INPUTS
    The organization object.

    .OUTPUTS
    The new MFA Policy as a PSObject

    .PARAMETER Org
    The Org object to apply the MFA Policy

    .PARAMETER Name
    Name of the MFA policy

    .PARAMETER Type
    Type of the FMA policy. Either "SOFT_OTP" or "SERVER_OTP"

    .PARAMETER Description
    Description of the MFA policy.

    .PARAMETER ExternalId
    External id for tracking

    .PARAMETER Active
    Is the policy is active. Defaults to $true

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Authentication%20Policy/post_MFAPolicies
        
    .EXAMPLE
    $p = (Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472") | Add-MFAPolicy -Name "test" -Type "SOFT_OTP"

    .NOTES
    POST: /authorize/scim/v2/MFAPolicies v2
#>
function Add-MFAPolicy {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateSet('SOFT_OTP','SERVER_OTP')]
        [String]$Type,

        [Parameter(Mandatory = $false, Position = 3)]
        [String]$Description,

        [Parameter(Mandatory = $false, Position = 4)]
        [String]$ExternalId,

        [Parameter(Mandatory = $false, Position = 5)]
        [Boolean]$Active = $true
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $request = @{
            "schemas"= @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:MFAPolicy");            
            "types" = @($Type);
            "name" = $Name;
            "description" = $Description;
            "externalId" = $ExternalId
            "active" = $Active;
            "resource" = @{
                "type" = "Organization";
                "value" = $Org.id;
             }
        }
        (Invoke-ApiRequest -Path "/authorize/scim/v2/MFAPolicies" -Version 2 -Method Post -Body $request -ValidStatusCodes @(201) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}