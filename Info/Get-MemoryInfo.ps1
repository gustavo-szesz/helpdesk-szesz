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

function Get-TopMemoryProcesses {
    [CmdletBinding()]
    param (
        [int]$TopN = 5
    )

    Get-Process |
        Group-Object ProcessName |
        ForEach-Object {
            $totalMemory = ($_.Group | Measure-Object -Property WorkingSet -Sum).Sum
            $processCount = $_.Count

            $firstProcess = $_.Group | Select-Object -First 1

            [PSCustomObject]@{
                Category      = 'TopProcess'
                ProcessName   = $_.Name
                Instances     = $processCount
                TotalMemoryMB = [math]::Round($totalMemory / 1MB, 2)
                Company       = $firstProcess.Company
                Result        = 'OK'

            }
        } |
        Sort-Object TotalMemoryMB -Descending |
        Select-Object -First $TopN
}