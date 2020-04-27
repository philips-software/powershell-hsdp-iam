## Powershell cmdlet API functionality coverage/status 
|topic|area|resource|version|Status|cmdlet(s)|Notes|
|-----|----|--------|-------|------|------|-----|
|Access management|Federation|GET /authorize/saml2/login|1|Future||
|||GET /authorize/saml2/logout|1|Future||
|||GET /authorize/oidc/login|1|Future||
|||GET /authorize/social/login|1|Future||
||OAuth2|POST /authorize/oauth2/token|2|Supported|Get-Headers, Get-TokenFromJWT|
|||GET /authorize/oauth2/authorize|2|Future||
|||GET /authorize/oauth2/userinfo|2|Supported|Get-UserInfo|
|||POST /authorize/oauth2/revoke|2|Future||
|||POST /authorize/oauth2/introspect|3|Supported|Get-Introspect|
|||GET /authorize/oauth2/refreshsession|2|Future||
|||GET /authorize/oauth2/endsession|2|Future||
|||POST /authorize/oauth2/introspect|3|Supported|Get-Introspect|
||Application|POST /authorize/identity/Application|1|Supported|Add-Application|
|||GET /authorize/identity/Application|1|Supported|Get-Application|Still need to implement by name| positionId and globalReferenceId
||Client|POST /authorize/identity/Client|1|Future||
|||GET /authorize/identity/Client|1|Future||
|||DELETE /authorize/identity/Client/{id}|1|Future||
|||PUT /authorize/identity/Client/{id}/$scopes|1|Future||
|||PUT /authorize/identity/Client/{id}|1|Future||
||Device|POST /authorize/identity/Device|1|Future||
|||GET /authorize/identity/Device|1|Future||
|||PUT /authorize/identity/Device|1|Future||
|||DELETE /authorize/identity/Device/deviceid|1|Future||
|||POST /authorize/identity/Device/{id}/$change-password|1|Future||
||Group|POST /authorize/identity/Group|1|Supported|Add-Group|
|||GET /authorize/identity/Group|1|Supported|Get-Groups|
|||PUT /authorize/identity/Group/{groupId}|1|Future||
|||DELETE /authorize/identity/Group/{groupId}|1|Supported|Remove-Group|
|||GET /authorize/identity/Group/{groupId}|1|Supported|Get-Group|
|||POST /authorize/identity/Group/groupID/$remove|1|Supported|Remove-GroupIdentity|
|||POST /authorize/identity/Group/{groupId}/$add-members|1|Supported|Set-GroupMember|
|||POST /authorize/identity/Group/{groupId}/$remove-members|1|Future||
|||POST /authorize/identity/Group/{groupId}/$assign-role|1|Supported|Set-GroupRole|
|||POST /authorize/identity/Group/{groupId}/$remove-role|1|Supported|Clear-GroupRole|
|||POST /authorize/identity/Group/{groupID}/$assign|1|Supported|Set-GroupIdentity|
||Organization|GET /authorize/identity/Organization|1|No Support|-|no plans to support old API|
|||POST /authorize/identity/Organization/{id}/$mfa|1|No Support|-|no plans to support old API|
|||POST /authorize/scim/v2/Organizations|2|Supported|Add-Org|
|||PUT /authorize/scim/v2/Organizations/{id}|2|Supported|Set-Org|
|||GET /authorize/scim/v2/Organizations/{id}|2|Supported|Get-Org|
|||GET /authorize/scim/v2/Organizations|2|Supported|Get-Orgs|
|||POST /authorize/scim/v2/MFAPolicies|2|Supported|Add-MFAPolicy|
|||PUT /authorize/scim/v2/MFAPolicies/{id}|2|Supported|Set-MFAPolicy|
|||GET /authorize/scim/v2/MFAPolicies/{id}|2|Supported|Get-MFAPolicy|
|||DELETE /authorize/scim/v2/MFAPolicies/{id}|2|Supported|Remove-MFAPolicy|
|||POST /authorize/scim/v2/Organizations/{id}/status|2|Supported|Set-Org|
||Proposition|POST /authorize/identity/Proposition|1|Supported|Add-Proposition|
|||GET /authorize/identity/Proposition|1|Supported|Get-Proposition|
||Role and Permission|POST /authorize/identity/Role|1|Supported|Add-Role|
|||GET /authorize/identity/Role|1|Supported|Get-Roles|
|||GET /authorize/identity/Role/{roleId}|1|Supported|Get-Role|
|||POST /authorize/identity/Role/{roleId}/$assign-permission|1|Supported|Add-Permissions|
|||POST /authorize/identity/Role/{roleId}/$remove-permission|1|Supported|Remove-Permissions|
|||GET /authorize/identity/Permission|1|Supported|Get-Permissions|
||Service|POST /authorize/identity/Service|1|Supported|Add-Service|
|||GET /authorize/identity/Service|1|Supported|Get-Service|
|||DELETE /authorize/identity/Service/{id}|1|Supported|Remove-Service|
|||PUT /authorize/identity/Service/{id}/$scopes|1|Future||
||User|POST /authorize/identity/User/$set-password|1|No Support|-|no plans to support old API|
|||POST /authorize/identity/User/$set-password|2|Future||
|||POST /authorize/identity/User/$change-password|1|Future||
|||POST /authorize/identity/User|1|No Support|-|no plans to support old API|
|||POST /authorize/identity/User|2|Supported|Add-User|
|||POST /authorize/identity/User/$resend-activation|1|No Support|-|no plans to support old API|
|||POST /authorize/identity/User/$resend-activation|2|Future||
|||POST /authorize/identity/User/{id}/$mfa|1|Future||
|||POST /authorize/identity/User/{id}/$unlock|1|Future||
|||DELETE /authorize/identity/User/{id}|1|No Suppprt|no plans to support old API|
|||DELETE /authorize/identity/User/{id}|2|Supported|Remove-User|
|||POST /authorize/identity/User/{id}/$kba|1|Future||
|||GET /authorize/identity/User/$kba|1|Future||
|||POST /authorize/identity/User/$reset-password|1|Future||
|||GET /authorize/identity/User/{id}/$password-policy|1|Future||
|||GET /authorize/identity/User|2|Supported|Get-User,Get-Users|
|||POST /authorize/identity/User/{id}/$change-loginid|2|Future||
|||POST /authorize/identity/User/{id}/$mfa-reset|2|Future||
||Email template|POST /authorize/identity/EmailTemplate|1|Future||
|||GET /authorize/identity/EmailTemplate|1|Future||
|||DELETE /authorize/identity/EmailTemplate/{id}|1|Future||
||Password policy|POST /authorize/identity/PasswordPolicy|1|Future||
|||GET /authorize/identity/PasswordPolicy|1|Future||
|||DELETE /authorize/identity/PasswordPolicy/{id}|1|Future||
|||PUT /authorize/identity/PasswordPolicy/{id}|1|Future||
|||GET /authorize/identity/PasswordPolicy/{id}|1|Future||
||legacy paths|GET /security/users/{userUUID}|1|Future||
|||PUT /security/users/{userUUID}|1|Future||
|||GET /security/users|1|Future||
|Policy management|Policy evaluation|POST /authorize/policy/$evaluate|3|Supported|Get-Evaluate|
||Policy provisioning|POST authorize/access/policy|1|Future||
|||GET authorize/access/policy|1|Future||
|||GET authorize/access/policy/{id}|1|Future||
|||DELETE authorize/access/policy/{id}|1|Future||
