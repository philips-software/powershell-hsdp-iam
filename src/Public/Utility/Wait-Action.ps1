function Wait-Action {
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$Condition,

        [ValidateNotNullOrEmpty()]
        [int]$Timeout = 300, 

        [Parameter()]
        [int]$RetryInterval = 5
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        
        $timer = [Diagnostics.Stopwatch]::StartNew()
        while (($timer.Elapsed.TotalSeconds -lt $Timeout) -and (-not (& $Condition))) {
            Start-Sleep -Seconds $RetryInterval
            $totalSecs = [math]::Round($timer.Elapsed.TotalSeconds, 0)
            Write-Verbose -Message "Waiting for action to complete for [$totalSecs] seconds"
        }
        $timer.Stop()
        if ($timer.Elapsed.TotalSeconds -gt $Timeout) {
            throw 'Action timeout'
        } else {
            Write-Verbose -Message 'Action completed'
        }
    }
 
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }     
}