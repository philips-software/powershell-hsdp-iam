<#
    .SYNOPSIS
    Create a new Authorization Policy

    .DESCRIPTION
    Creates a new policy under the specified policySetId. A policySetId is equivalent to application name that must be passed during policy evaluation.
    A user with POLICY.WRITE permission can create policy within an organization. If you don’t have this permission, ask your IAM org admin to assign this permission to your account.
    NOTE Maximum number of policy creation allowed in specified policySetId is 100.

    Subject Types - Each subject type requires a specific value to get it processed. The values supported by each subject type is as follows:

        AuthenticatedUsers - Only authenticated users are allowed to do certain actions in the requested resource set.

        No values are required in case of this subject. Requested user subject token (OAuth2.0 Bearer Token) MUST be passed during policy evaluation (/authorize/policy/$evaluate).

        Example:
            {
                "type": "AuthenticatedUsers"
            }

        AuthenticatedPermissions - Only authenticated users with requested permission will be allowed to do certain actions in the requested resource set.
        No values are required in case of this subject. Requested permission MUST be passed during policy evaluation when this subject is configured.

        Example:
            {
                "type": "AuthenticatedPermissions"
            }

        Permission - Only authenticated users having any one permission specified in anyOf array list will be allowed to do certain actions in the requested resource set.

        A registered permission name can be passed as value object. Note that requested permission need not be passed during policy evaluation as it is already set in this policy configuration.
        NOTE Currently only ONE permission is allowed to set in anyOf field.

        Example:
            {
                "type": "Permission",
                "value": {
                    "anyOf": ["PRACTIONER.ANY"]
                }
            }

        Group - Only authenticated users who has a membership in specified group(s) will be allowed to do certain actions in requested resource set.

        Unique ID of the group need to be passed as value object. If user has membership in any one group specified in anyOf array list, policy decision
        will return SUCCESS.NOTE Maximum number of group IDs allowed is 10.

        Example:
            {
                "type": "Group",
                "value": {
                    "anyOf": ["1ab3b096-0b37-4a90-89d0-520b65a80bdc"]
                }
            }

    Condition - Condition allows the client to set certain environment conditions or circumstances underwhich the request should be processed.
    Supported condition types are as follows:

        Scope - Users with specific OAuth2 client scope(s) will be allowed to do certain actions in requested resource set.

        Any registered scopes of the client can be set as value object. User must have all scopes specified in allOf array list for the policy decision to return SUCCESS.
        NOTE Maximum number of scopes allowed is 100.
        Example:
        {
            "type": "Scope",
            "value": {
                "allOf": ["mail", "openid"]
            }
        }

    .INPUTS
    Accepts the Org PSObject from the pipeline

    .OUTPUTS
    The new authorization policy object

    .PARAMETER Org
    The managing organization PSObject

    .PARAMETER Name
    Name of the policy

    .PARAMETER PolicySetId
    Unique ID under which the policy need to be created. policySetId is case-sensitive. This is a unique ID under which policies are created and was generated during your IAM onboarding.
    If you don’t have it, open a ticket with HSDP Support requesting your policySetID. Include your IAM org name, policy name and the application under which the policy was created.

    .PARAMETER Resources
    The array of resource uri patterns to which the policy applies

    .PARAMETER Actions
    A hashtable keyed with action names and values as booleans

    .PARAMETER SubjectType
    The subject type

    .PARAMETER Subjects
    An array of subjects. Only required for SubjectType = Group|Permission

    .PARAMETER Conditions
    An array of conditions

    .EXAMPLE
    $myPolicy = Add-AuthPolicy -Org $org -Name MyPolicy -PolicySetId "ef08d8d7-4395-4b22-a99a-5855d50db7d9" -Resources @("https://*:*/service/practitioner*?*") `
        -Actions @{ POST=$true; GET=$true; DELETE=$false } -SubjectType "Permission" -Subjects @("PRACTITIONER.ANY") -Conditions @("openid", "mail", "read_only")

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/policy-provisioning-api#/Policy/post_authorize_access_Policy

    .NOTES
    POST: ​/authorize​/access​/Policy v1
#>
function Add-AuthPolicy {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateLength(1, 128)]
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateLength(1, 64)]
        [String]$PolicySetId,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Resources,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]$Actions,

        [Parameter(Position = 5)]
        [ValidateSet("AuthenticatedUsers", "AuthenticatedPermissions", "Permission", "Group")]
        [String]$SubjectType,

        [Parameter(Mandatory = $true, Position = 6)]
        [String[]]$Subjects,

        [Parameter(Mandatory = $true, Position = 7)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Conditions
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $body = @{
            "name" = $Name
            "policySetId"= $PolicySetId
            "managingOrganization" = $Org.Id
            "resources" = $Resources
            "actions" = $Actions
            "subject" =  @{
                type = $SubjectType
            }
            "condition" = @{
                type = "Scope"
                value = @{
                    allOf = $Conditions
                }
            }
        }
        # Per the documentation the value is only required for these subject types
        if ($SubjectType -eq "Group" -or $SubjectType -eq "Permission") {
            $body.subject.Add("value", @{ anyOf = $Subjects })
        }
        Write-Output (Invoke-ApiRequest -Path "/authorize/access/Policy" -Version 1 -Method Post -Body $body -ValidStatusCodes @(201) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}