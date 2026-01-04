function Test-GatewayConnectivity {
    [CmdletBinding()]
    param (
        [int]$Count = 2, 
        [int]$Timeout = 1000
    )

    Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -ne $null } |
    ForEach-Object {
        $gateway = $_.IPv4DefaultGateway.NextHop
        $interface = $_.$interfaceAlias

        $reachable = Test-Connection `
            -ComputerName $gateway `
            -Count $Count `
            -Quiet `
            -TimeoutMilliseconds $TimeoutMs
        
        if ($reachable) {
            [PSCustomObject]@{
                Category = 'Network'
                Name     = $interface
                Target   = 'Default Gateway'
                Address  = $gateway
                Status   = 'Reachable'
                Detail   = 'Gateway respondeu ao ping'
                Result   = 'OK'
            }
        }
        else {
            [PSCustomObject]@{
                Category = 'Network'
                Name     = $interface
                Target   = 'Default Gateway'
                Address  = $gateway
                Status   = 'Unreachable'
                Detail   = 'Sem resposta do gateway'
                Result   = 'ALERT'
            }
        }
    }
    
}