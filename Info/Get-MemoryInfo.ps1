function Get-MemoryInfo {
    [CmdletBinding()]
    param ()

    $os = Get-CimInstance Win32_OperatingSystem
    
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = $totalRAM - $freeRAM

    [PSCustomObject]@{
        Category    = 'MemoryInfo'
        TotalRAM    = $totalRAM
        FreeRAM     = $freeRAM
        UsedRAM     = $usedRAM
        Result      = 'OK'
    }
}
