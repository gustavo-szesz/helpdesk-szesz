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