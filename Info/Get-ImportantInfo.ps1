function Get-ImportantInfo {
    [CmdletBinding()]
    param ()

    Get-SystemInfo
    Get-MemoryInfo
    Get-DiskInfo
    Get-IPConfiguration
}