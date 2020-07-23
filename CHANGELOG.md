## 0.1.29

* Move distribution to Powershell Gallary.

## 0.1.27

* Added cmdlet Set-AppServiceScope
* Update contribute for coding style and best practices reference

## 0.1.26

* Added cmdlets to support Device API

## 0.1.25

* Added support to use refresh token to retrieve new access token if the access token expires
* Re-worked how authentication value is stored between cmdlets
* Renamed `Get-Headers` to `Get-AuthenticationHeader` - changed return value to string that just contains value for the authenticate header  rather than a hashtable of a subset of header values.
* `Set-Config` now clears cached authentication and re-authenticates

## 0.1.24 - Add Cmdlets for PasswordPolicy

Added Cmdlets:
* `Add-PasswordPolicy`
* `Get-PasswordPolicies`
* `Get-PasswordPolicy`
* `Set-PasswordPolicy`
* `Remove-PasswordPolicy`
* `Get-UserKba`
* `Reset-UserPassword`

## 0.1.23 - Updates for HSDP May 2020 release

Changed documentation and params to support batches of 100 for:
* `Add-Group`
* `Set-GroupRole`
* `Add-Permissions`

Changed `Add-Permissions` param -Role to -Roles to support multiple

## 0.1.22 - Added more user cmdlets

Renamed ``Get-Users`` cmdlet to ``Get-UserIds`` for clarity. Get-UserIds now support paging

New Cmdlets added:
* `New-UserPassword`
* `New-UserResendActivation`
* `Reset-UserMfa`
* `Set-UserKba`
* `Set-UserNewLoginId`
* `Set-UserPassword`
* `Set-UserUnlock`

## 0.1.21 - Added new cmdlets for OAuth2 Client API.

Configuration changes:
* Removed unused "OAuth2Credentials" config params
* Support for scopes has now been added to the CmdLets New-Config and Read-Config to support the scopes requested when performorming.
* The default scopes requested of `/authorize/oauth2/token` is `@("profile","email","read_write")` unless otherwise specified

The following CmdLets have been renamed, support pagination for querying multiple resources, and support all query parameters of the API
* `Get-Proposition` renamed to `Get-Propositions`
* `Get-Application` renamed to `Get-Applications`

Improvements:
* Established and configured a new HSDP tenant dedicated to this project.
* Integration tests now part of build pipeline
* Minor inline documentation updates

## 0.1.19 - Unit Testing Coverage Complete

## 0.1.1 - Version build & published from github action

## 0.0.1 - Inital release

