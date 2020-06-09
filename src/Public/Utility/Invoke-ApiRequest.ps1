<#
    .SYNOPSIS
    Calls a REST Web Request

    .DESCRIPTION
    This is utility function to making calling REST methods simplier and mockable

    .PARAMETER Path
    The url path to call (should not include the basehost address)

    .PARAMETER Body
    The body of the request

    .PARAMETER Method
    The http method

    .PARAMETER ValidStatusCodes
    An array of http status codes that are considered valid. defaults to @(200,201,202,203,204,205,206,207,208,226)

    .PARAMETER Version
    The version to use in the header. Defaults to "1"

    .PARAMETER Base
    The base url to use. If not supplied then the current configuration IdmUrl is used

    .PARAMETER ContentType
    The content type to send in the header. Defaults to "application/json"

    .PARAMETER Authorization
    The value for the authorization header.

    .PARAMETER AddHsdpApiSignature
    Indicates that an HSDP Api signature should be added to the call

    .PARAMETER AddIfMatch
    Indicates that an "AddIfMatch" headers should be added. Assumes the body of the request contains a .meta.version property

    .PARAMETER AdditionalHeaders
    Adds any additional headers to the request

    .PARAMETER ReturnResponseHeader
    Indicates the response header should be returned and not the body

    .PARAMETER ProcessHeader
    A script block that will accept the headers and the API response and process it returning a new response object

#>
function Invoke-ApiRequest {

    [CmdletBinding()]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification='clone dictionary')]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(ValueFromPipeline=$true)]
        [System.Object]
        $Body,

        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = "Get",

        [int[]]
        $ValidStatusCodes = @(200,201,202,203,204,205,206,207,208,226),

        [string]
        $Version = "1",

        [string]
        $Base,

        [string]
        $ContentType = "application/json",

        [string]
        $Authorization,

        [Switch]
        [Parameter(Mandatory=$false)]
        $AddHsdpApiSignature,

        [Switch]
        [Parameter(Mandatory=$false)]
        $AddIfMatch,

        [hashtable]
        [Parameter(Mandatory=$false)]
        $AdditionalHeaders = @{},

        [Switch]
        [Parameter(Mandatory=$false)]
        $ReturnResponseHeader,

        [scriptblock]
        [Parameter(Mandatory=$false)]
        $ProcessHeader
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $headers = Get-Variable -Name _headers -Scope Script -ValueOnly

        if (-Not $Base) {
            $config = Get-Config
            $Base = $config.IdmUrl
        }
        $url = "$($Base)$($Path)"
        Write-Debug "URL: $($url)"

        $HeaderCopy = @{}
        ($headers | ConvertTo-Json | ConvertFrom-Json).psobject.properties | ForEach-Object { $HeaderCopy[$_.Name] = $_.Value }
        $HeaderCopy."api-version" = $Version
        $HeaderCopy."Content-Type" = $ContentType
        if ($Authorization) {
            $HeaderCopy."Authorization" = $Authorization
        }
        if ($AddHsdpApiSignature) {
            $addHeaders = Get-ApiSignatureHeaders
            $addHeaders.keys | Where-Object {$_ -notin $HeaderCopy.keys} | ForEach-Object { $HeaderCopy[$_] = $addHeaders[$_] }
        }
        if ($AddIfMatch -and $Body.meta -and $Body.meta.version ) {
            $HeaderCopy."If-Match" = $Body.meta.version
            $Body = $Body | Select-Object -Property * -Exclude meta
        }
        $HeaderCopy = $HeaderCopy + $AdditionalHeaders

        Write-Debug "HEADERS: $($HeaderCopy | ConvertTo-Json)"

        $outcome = try {
            if ($Body) {
                if ($HeaderCopy."Content-Type" -eq "application/json") {
                    Write-Debug "REQUEST BODY: $($Body | ConvertTo-Json -Depth 99)"
                    Write-Debug "INVOKING REQUEST..."
                    $response = Invoke-WebRequest -Uri $url -Method $Method -Headers $HeaderCopy -Body ($Body | ConvertTo-Json -Depth 99) -ErrorAction Stop
                } else {
                    $response = Invoke-WebRequest -Uri $url -Method $Method -Headers $HeaderCopy -Body $Body -ErrorAction Stop
                }
            } else {
                $response = Invoke-WebRequest -Uri $url -Method $Method -Headers $HeaderCopy -ErrorAction Stop
            }
            Write-Debug "HTTP STATUS: $($response.StatusCode)"
            @{ status = $response.StatusCode; response = $response; headers = [System.Collections.Hashtable]::new($response.Headers) }
        } catch {
            $e = $_.Exception
            $line = $_.InvocationInfo.ScriptLineNumber
            Write-Debug "caught exception: $e at $line"
            Write-Debug "HTTP STATUS: $($_.Exception.Response.StatusCode.value__)"
            Write-Debug $_
            @{ status = $_.Exception.Response.StatusCode.value__; response = $null; detail = $_ }
        }
        if (($outcome.status -in $ValidStatusCodes)) {
            if ($null -ne $outcome.response) {
                $content = $outcome.response.content
                $objContent = $outcome.response.content | ConvertFrom-Json -AsHashtable
                Write-Debug "RESPONSE BODY: $($content)"
                Write-Debug "RESPONSE HEADERS: $($outcome.response.Headers | ConvertTo-Json)"
                # copy the eTag header value to the meta element on the resource
                if ([bool]($outcome.response.Headers.ETag) -eq $true -and -not $ReturnResponseHeader) {
                    Write-Debug "Adding meta.version tag from etag header $($outcome.headers.ETag)"
                    $objContent | Add-Member NoteProperty meta (New-Object PSObject -Property @{ version = $outcome.response.Headers.ETag } )
                    $content = ($objContent | ConvertTo-Json)
                }
                if ($ReturnResponseHeader) {
                    Write-Output ($outcome.headers | ConvertTo-Json)
                } else {
                    if ($ProcessHeader) {
                        Write-Debug "Processing Header Callback"
                        $PreviousPreference = $ErrorActionPreference
                        $ErrorActionPreference = 'Stop'
                        $objContent = Invoke-Command -ScriptBlock $ProcessHeader -ArgumentList $outcome.headers,$objContent
                        $ErrorActionPreference = $PreviousPreference
                        Write-Output $objContent
                    } else {
                        Write-Output ($content | ConvertFrom-Json)
                    }
                }
            }
        } else {
            throw "invalid response code $($outcome.status): $($outcome.detail)"
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}