<#
    .SYNOPSIS
    Add a user account.

    .DESCRIPTION
    Creates a new user within an organization. A user can be registered in the system in two ways

    Admin Managed
    A user with 'USER.WRITE' permission can register users within an organization on behalf of the user.
    In this case, managingOrganization is mandatory and user will be created under specified organization.
    The registration triggers an account activation email to the registered email address of the user.
    Upon activation, the user shall set the password for the account and update the complete user profile.

    Self Managed
    Consumer applications can trigger user registration in a way that does not need an organization.
    All self-managed users will be created under a system organization called Consumer organization.
    Self-registration sends an account activation email to the registered email address of the user.
    Upon activation, the user shall set the password for the account and update the complete user profile.
    Self managed registration request must set isAgeValidated property to true.

    Minimum properties required to create a user are loginId, emailAddress, givenName and familyName.

    .INPUTS
    An organization resource object

    .OUTPUTS
    A user resource object

    .PARAMETER Org
    An organization resource object to associate the user

    .PARAMETER LoginId
    Unique login ID for the user.
    pattern: ^((?![~`!#%^&*()+={}[\]|/\\<>,;:"'?])[\S])*$

    .PARAMETER Email
    Email ID
    Allowed characters are _A-Za-z0-9-@ with a minimum length of 3, max of 255.

    The sequence of characters of email address should be as follows:
        a. Any character one or more times.[ _ A to Z a to z 0 to 9 to +]
        b. If there is a '.' then it should also be followed by one or more characters [ _ A to Z a to z 0 to 9 -]. A '.'  without characters following it is not allowed
        c. '@' is required
        d. Any character[ A to Z a to z 0 to 9 -] one or more times
        e. If there is a '.' then it should also be followed by one or more characters [A to Z a to z 0 to 9].
        f. A '.' without characters following it is not allowed A '.' followed by any alphabet 2 or more times

    .PARAMETER LoginId
    Unique login ID for the user.
    pattern: ^((?![~`!#%^&*()+={}[\]|/\\<>,;:"'?])[\S])*$

    .PARAMETER GivenName
    Given names (not always 'first'). Includes middle names. pattern: ^((?![0-9,#<>~&^%?*|/\\{}[\]!@$():;+=''"])[\S])*$

    .PARAMETER FamilyName
    Family name (often called 'Surname'). pattern: ^((?![0-9,#<>~&^%?*|/\\{}[\]/!@$():;+=''"])[\S])*$

    .PARAMETER MobilePhone
    Mobile number
    pattern: ^([0-9]{10,20})$
    Allowed 0-9 with a minimum length of 10, max of 20.
    Ex: 1234512345

    .EXAMPLE
    $user = Add-User -Org $org -LoginId "test01" -Email "asdfasdf@mailinator.com" -MobilePhone "1234512345" -FamilyName "FAMILY" -GivenName "GIVEN"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api-v2#/User%20Identity/post_authorize_identity_User

    .NOTES
    POST: /authorize/identity/User v2
#>
function Add-User {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]$Org,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginId,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$Email,

        [Parameter(Mandatory, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [String]$GivenName,

        [Parameter(Mandatory, Position = 4)]
        [ValidateNotNullOrEmpty()]
        [String]$FamilyName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$MobilePhone,

        # These are accepted by API but there is no way to retrieve the fields so they are excluded until fixed
        # [Parameter()]
        # [String]$FaxPhone,

        # [Parameter()]
        # [String]$ContactUrl,

        # [Parameter()]
        # [String]$HomeAddress,

        # [Parameter()]
        # [String]$HomeCity,

        # [Parameter()]
        # [String]$HomeState,

        # [Parameter()]
        # [String]$HomeCountry,

        # [Parameter()]
        # [String]$HomePostalCode,

        # [Parameter()]
        # [String]$WorkAddress,

        # [Parameter()]
        # [String]$WorkCity,

        # [Parameter()]
        # [String]$WorkState,

        # [Parameter()]
        # [String]$WorkCountry,

        # [Parameter()]
        # [String]$WorkPostalCode,

        # [Parameter()]
        # [String]$TempAddress,

        # [Parameter()]
        # [String]$TempCity,

        # [Parameter()]
        # [String]$TempState,

        # [Parameter()]
        # [String]$TempCountry,

        # [Parameter()]
        # [String]$TempPostalCode,

        # [Parameter()]
        # [String]$PreferredLanguage,

        [Parameter()]
        [Bool]$AgeValidated = $true
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $telcom = @()
        $telcom +=  @{"system"="email";"value"=$Email;}
        if ($MobilePhone) {
            $telcom +=  @{"system"="mobile";"value"=$MobilePhone;}
        }
        # if ($FaxPhone) {
        #     $telcom +=  @{"system"="fax";"value"=$FaxPhone;}
        # }
        # if ($ContactUrl) {
        #     $telcom +=  @{"system"="url";"value"=$ContactUrl;}
        # }
        Write-Debug $Org.id
        $body = @{
            "resourceType"= "Person";
            "loginId"= $LoginId;
            "managingOrganization"= $Org.id;
            "name" = @{
                "family"= $FamilyName;
                "given"= $GivenName;
            };
            "telecom" = $telcom;
            "isAgeValidated" = $AgeValidated
        }
        # $address = @()
        # if ($HomeAddress) {
        #     $address += @{"use"="home";"text"=$HomeAddress;"city"=$HomeCity;"state"=$HomeState;"postalCode"=$HomePostalCode;"country"=$HomeCountry}
        # }
        # if ($WorkAddress) {
        #     $address += @{"use"="work";"text"=$WorkAddress;"city"=$WorkCity;"state"=$WorkState;"postalCode"=$WorkPostalCode;"country"=$WorkCountry}
        # }
        # if ($TempAddress) {
        #     $address += @{"use"="temp";"text"=$TempAddress;"city"=$TempCity;"state"=$TempState;"postalCode"=$TempPostalCode;"country"=$TempCountry}
        # }
        # if ($Address) {
        #     $body.address = $address;
        # }
        # if ($PreferredLanguage) {
        #     $body.preferredLanguage = $PreferredLanguage
        # }

        $response = (Invoke-ApiRequest -Path "/authorize/identity/User" -Version 2 -Method Post -Body $body `
            -AddHsdpApiSignature `
            -ValidStatusCodes @(200,201) `
            -ProcessHeader { # Used to parse the user id from the end of the location header
                $segments = ([System.Uri]"http://localhost$($args[0].Location[0])").segments
                $body.Id = $segments[$segments.Count-1]
                Write-Output $body
            })
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}