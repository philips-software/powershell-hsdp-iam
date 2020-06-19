function Test-DeviceCmdlets {
    param($Org, $Application)

    $Password = "P@ssw0rd1"

    # CmdLet: Add-Device
    $addDevice = Add-Device -Org $Org -App $Application -LoginId "$(((new-guid).Guid).Substring(0,20))" -ExternalId "$(((new-guid).Guid).Substring(0,20))" `
                -Password $Password -GlobalReferenceId "$(((new-guid).Guid).Substring(0,20))" -Text "foobar"

    # CmdLet: Get-Devices
    $getDevice = Get-Devices -Org $Org -Id $addDevice.Id
    if ($addDevice.id -ne $getDevice.id) {
        Write-Warning "Cross check of Add-Device and Get-Device failed"
        Write-Warning "$($addDevice | ConvertTo-Json)"
        Write-Warning "$($getDevice | ConvertTo-Json)"
    }

    # CmdLet: Set-Device
    $getDevice.Text = "updated text"
    $setDevice = Set-Device -Device $getDevice
    $setGetDevice = Get-Devices -Org $org -Id $setDevice.Id
    if ($getDevice.Text -ne $setGetDevice.Text) {
        Write-Warning "Cross check of Set-Device and Get-Devices failed"
        Write-Warning "$($getDevice | ConvertTo-Json)"
        Write-Warning "$($setGetDevice | ConvertTo-Json)"
    }

    # CmdLet: New-DevicePassword
    New-DevicePassword -Device $addDevice -Old $Password -New "P@ssw0rd2"

    # CmdLet: Remove-Device
    Remove-Device -Device $addDevice -Force

    # create and return a new device
    Write-Output (Add-Device -Org $Org -App $Application -LoginId "$(((new-guid).Guid).Substring(0,20))" -ExternalId "$(((new-guid).Guid).Substring(0,20))" `
        -Password $Password -GlobalReferenceId "$(((new-guid).Guid).Substring(0,20))")
}