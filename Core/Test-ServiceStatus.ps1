function Test-ServiceStatus {
    param (
        [string[]]$CriticalServices
    )
    Get-Service | ForEach-Object {
        $result = if ($CriticalServices -contains $_.Name -and $_.Status -ne "Running") {
            "ALERT"
        }  else {
            "OK"
        }

        [PSCustomObject]@{
            Category = "Service"
            Name     = $_.Name
            Status   = $_.Status
            Result   = $result
        }
    }
    
}