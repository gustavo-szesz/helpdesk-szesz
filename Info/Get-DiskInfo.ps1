function Get-DiskInfo {
    [CmdletBinding()]
    param ()
    
    Get-Volume | Where-Object { $_.DriveLetter -ne $null } | ForEach-Object {
        $totalGB = [math]::Round($_.Size / 1GB, 2)
        $freeGB = [math]::Round($_.SizeRemaining / 1GB, 2)
        $usedGB = [math]::Round($totalGB - $freeGB, 2)
        $usedPercent = if ($totalGB -gt 0) { 
            [math]::Round(($usedGB / $totalGB) * 100, 2) 
        } else { 
            0 
        }
        
        [PSCustomObject]@{
            Category      = 'DiskInfo'
            Drive         = "$($_.DriveLetter):"
            Label         = $_.FileSystemLabel
            FileSystem    = $_.FileSystem
            TotalSize     = "$totalGB GB"
            UsedSpace     = "$usedGB GB"
            FreeSpace     = "$freeGB GB"
            UsedPercent   = "$usedPercent%"
            HealthStatus  = $_.HealthStatus
            Result        = if ($usedPercent -gt 90) { 'ALERT' } else { 'OK' }
        }
    }
}

function Get-DiskCleanupInfo {
    [CmdletBinding()]
    param (
        [string]$DriveLetter = 'C'
    )

    $tempPath = $env:TEMP
    $tempSize = (Get-ChildItem -Path $tempPath -Recurse -File -ErrorAction SilentlyContinue | 
        Measure-Object -Property Length -Sum).Sum

    if ($null -eq $tempSize) { $tempSize = 0 }

    $tempSizeGB = [math]::Round($tempSize / 1GB, 2)
    $tempFileCount = (Get-ChildItem -Path $tempPath -Recurse -File -ErrorAction SilentlyContinue).Count

    [PSCustomObject]@{
        Category        = 'CleanupInfo'
        Location        = '%TEMP% (User)'
        Path            = $tempPath
        SizeGB          = $tempSizeGB
        FileCount       = $tempFileCount
        Result          = if ($tempSizeGB -gt 1) { 'ALERT' } else { 'OK' }
    }

    # Windows\Temp
    $winTempPath = 'C:\Windows\Temp'
    if (Test-Path $winTempPath) {
        $winTempSize = (Get-ChildItem -Path $winTempPath -Recurse -File -ErrorAction SilentlyContinue | 
            Measure-Object -Property Length -Sum).Sum
        
        if ($null -eq $winTempSize) { $winTempSize = 0 }
        
        $winTempSizeGB = [math]::Round($winTempSize / 1GB, 2)
        $winTempFileCount = (Get-ChildItem -Path $winTempPath -Recurse -File -ErrorAction SilentlyContinue).Count

        [PSCustomObject]@{
            Category      = 'CleanupInfo'
            Location      = 'Windows\Temp'
            Path          = $winTempPath
            SizeGB        = $winTempSizeGB
            FileCount     = $winTempFileCount
            Result        = if ($winTempSizeGB -gt 5) { 'ALERT' } else { 'OK' }
        }
    }
}