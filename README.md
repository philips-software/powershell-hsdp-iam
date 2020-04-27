# powershell-hsdp-iam

[![Slack](https://philips-software-slackin.now.sh/badge.svg)](https://philips-software-slackin.now.sh)
![CI](https://github.com/philips-software/powershell-hsdp-iam/workflows/CI/badge.svg)
[![Nuget](https://img.shields.io/nuget/v/hsdp-iam)](https://www.nuget.org/packages/hsdp-iam/)

**Description**: This powershell module contains cmdlets to work against the HSDP IAM APIs using a powershell approach.

  - **Technology stack**: Microsoft Powershell. Compatible with PS Core.
  - **Key concepts** powershell  (technical, philosophical, or both) important to the user’s understanding.
  - **Status**:  Alpha. See ToDos. [CHANGELOG](CHANGELOG.md).

## Status

The intent of this module is to cover all API functionality available in the HSDP IAM APIs.

The coverage is tracked in [coverage.md](coverage.md)

## Dependencies

* Powershell 7/Core recommend
* Pester for unit tests

## Installation

This package is available on [nuget.org](https://www.nuget.org/packages/hsdp-iam)

```
nuget install hsdp-iam-{version}
Import-Module hsdp-iam-{version}/hsdp-iam.psm1 -Scope Local
```

## Configuration
A new configuration file may be created using the New-Config cmdlet. The cmdlet will prompt for the following configuration parameters:

| Value             | Example | Purpose | Notes|
|-------------------|---------|---|----|
| HSDP IAM URL | https://iam-integration.us-east.philips-healthsuite.com | IAM base URI | Do not include trainling slash
| HSDP IDM URL | https://idm-integration.us-east.philips-healthsuite.com   | IDM base URI | Do not include trainling slash
| HSDP Username and Password |  | Credentials with org administrative role | always required
| HSDP ClientId and Secret | | IAM client key and secret | always required
| HSDP App Shared Key and Secret | | App shared key and secret  | required for API Signature headers
| HSDP OAuth2 ClientId and Secret | | OAuth2 Client ID and password | required for evaulate calls

The configuration will be saved to a file named ```./config.xml``` The secrets provided will be encrypted the configuration when using the windows platform.

## Import configuration
To authenticate using the configuration execute the following cmdlet:

```
Set-FileConfig
```

## Concepts:

These powershell cmdlets have been designed to follow common powershell patterns:

### Online Help

The cmdlets all contain online help which can be obtains by using the Get-Help cmdlet. For instance:

```
Get-Help Get-Org
```

### Objects
The cmdlets in this module return PSObjects from most functions that match the HSDP models. So for example:

```
$org = Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"
```

The $Org will be represented in the following PSObject:

```
schemas           : {urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:Organization}
id                : d578177f-f3db-4919-805a-b382c6fa0032
name              : _testorg1
parent            : @{value=e5550a19-b6d9-4a9b-ac3c-10ba817776d4; $ref=https://idm-integration.us-east.philips-healthsuite.com/authorize/scim/v2/Organizations/e5550a19-b6d9-4a9b-ac3c-10ba817776d4}
active            : True
inheritProperties : True
owners            : {@{value=36268f6b-828e-454c-aba8-8c2044fb19f9; primary=True}}
createdBy         : @{value=36268f6b-828e-454c-aba8-8c2044fb19f9}
modifiedBy        : @{value=36268f6b-828e-454c-aba8-8c2044fb19f9}
meta              : @{resourceType=Organization; created=2/17/2020 6:05:25 PM; lastModified=2/17/2020 8:36:25 PM; location=https://idm-integration.us-east.philips-healthsuite.com/authorize/scim/v2/Organizations/d578177f-f3db-4919-805a-b382c6fa0032;
                    version=W/"617601800"}
```

The PSObjects are used by other CmdLets to simplify parameter passing. For instance:

```
$groups = Get-Groups -Org $org
```

Will return all the groups in the org object passed to the cmdlet.

### Object Update (version meta)
Cmdlets that perform updates will leverage the $object.meta.version property to pass the proper ETag.

### Pipeline support

Many cmdlets use ValueFromPipeline allowing composition such as in the following example to remove all users from an org:

```
Get-Users $org | Remove-User
```

### Debugging and Tracing

The cmdlets have all be instrumented with Debug and Verbose information. This can be enabled using:

```
$DebugPreference="continue"
$VerbosePreference="continue"
```

## Cmdlet Categories
- Configuration
- Application
- Group
- Organization
- Proposition
- Role
- Service
- User
- Utility

## Recepies

### Add Org and User

```
$parentOrg = Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"
$org = Add-Org -ParentOrg $parentOrg -Name "MyNewOrg"
$user = Add-User -LoginId "test01" -Email "asdfasdf@mailinator.com" -MobilePhone "1234512345" -FamilyName "FAMILY" -GivenName "GIVEN" -Org $org
```

### Create Proposition, Application, Service Identity and generate a JWT

```
$org = Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"
$propId = ([GUID]::NewGuid().ToString('D'))
$prop = Add-Proposition -Org $org -Name "My Proposition" -GlobalReferenceId $propId

$appId = ([GUID]::NewGuid().ToString('D'))
$app = Add-Application -Proposition $prop -Name "My Application" -GlobalReferenceId $appId

$keyFile = "$($appName).pem"
# create a new service and write a key file
$service = Add-Service -Application $app -Name "My Service" -PrivateKeyPath $keyFile

$jwt = New-HsdpJWT -Service $service -KeyFile $keyFile
```

### Assign multiple users into group

```
$org = Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"
Set-UsersInGroup -Org $Org -GroupName "My Group" -UserIds @("user1@mailinator.com", "user2@mailinator.com")
```

### Find a user by email address in an org and display all the permissions for all the roles

```
$user = (Get-Users -Org $org | Get-User | Where-Object { $_.emailAddress -eq "user1@mailinator.com" })
$user.memberships.roles | % { get-roles -Name $_ } | get-permissions
```

### Display all the email addresses of users who have never verified their email across all organizations

```
get-orgs | get-users | get-user | Where-Object { $_.accountStatus.emailVerified -ne "True" } | Select-Object -ExpandProperty emailAddress
```
## How to test the software

Pester tests are a WIP. Use ./iam-api.tests.ps1 to execute tests.

## Known issues

None

## Contact / Getting help

mark.lindell@philips.com

## License

Link to [LICENSE.md](LICENSE.md)


## Credits and references

1. Inspiration for powershell approach taken from from [JiraPS](https://github.com/AtlassianPS/JiraPS)

[![Slack](https://philips-software-slackin.now.sh/badge.svg)](https://philips-software-slackin.now.sh)
