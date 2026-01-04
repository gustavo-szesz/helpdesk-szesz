function Get-SystemInfo {
    [CmdletBinding()]
    param ()

    $timestamp = Get-Date
    $bios = Get-CimInstance Win32_BIOS
    $computerSystem = Get-CimInstance Win32_ComputerSystem

    [PSCustomObject]@{
        Category        = 'SystemInfo'
        Timestamp       = $timestamp
        ComputerName    = $computerSystem.Name
        Domain          = $computerSystem.Domain
        Manufacturer    = $computerSystem.Manufacturer
        Model           = $computerSystem.Model 
        SerialNumber    = $bios.SerialNumber
        Result          = 'OK'
    }
}
