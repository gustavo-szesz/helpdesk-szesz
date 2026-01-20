function Get-ImportantInfo {
    [CmdletBinding()]
    param ()

    Get-SystemInfo
    Get-MemoryInfo
    Get-TopMemoryProcesses
    Get-DiskInfo
    Get-DiskCleanupInfo
    Get-IPConfiguration
}

function Get-ImportantInfoJson {
    [CmdletBinding()]
    param ()

    $timestamp = (Get-Date).ToString('o')
    $items = @()
    $items += Get-SystemInfoJson
    $items += Get-MemoryInfoJson
    $items += Get-TopMemoryProcessesJson
    $items += Get-DiskInfoJson
    $items += Get-DiskCleanupInfoJson
    $items += Get-IPConfigurationJson

    
    return [PSCustomObject]@{
        ComputerName      = $env:COMPUTERNAME
        Timestamp         = $timestamp
        Status            = 'OK'
        Data              = $items
    }
}