function Get-IPConfiguration {
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


