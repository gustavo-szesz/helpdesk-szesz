function Test-ServiceStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$CriticalServices
    )

    foreach ($serviceName in $CriticalServices) {

        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

        if (-not $service) {
            [PSCustomObject]@{
                Category = 'Service'
                Name     = $serviceName
                Status   = 'NotFound'
                Result   = 'ALERT'
            }
            continue
        }

        $result = if ($service.Status -ne 'Running') { 'ALERT' } else { 'OK' }

        [PSCustomObject]@{
            Category = 'Service'
            Name     = $service.Name
            Status   = $service.Status
            Result   = $result
        }
    }
}
