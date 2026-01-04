function Get-DiskInfo {
    [CmdletBinding()]
    param ()
    
    # Opção 1: Get-Volume (mais moderno)
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
