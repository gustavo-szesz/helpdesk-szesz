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

function Test-IPConfiguration {
    [CmdletBinding()]
    param ()
    
    Get-NetIPConfiguration | ForEach-Object {
        [PSCustomObject]@{
            Category       = 'Network'
            Name           = $_.InterfaceAlias
            IPv4Address    = ($_.IPv4Address | ForEach-Object { $_.IPAddress }) -join ', '
            IPv6Address    = ($_.IPv6Address | ForEach-Object { $_.IPAddress }) -join ', '
            DefaultGateway = ($_.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', '
            DNSAddresses   = ($_.DNSServer | ForEach-Object { $_.ServerAddresses }) -join ', '
            Result         = 'OK'
        }
    }
}

function Get-IPConfigurationReport {
    Get-SystemInfo
    Test-IPConfiguration
}