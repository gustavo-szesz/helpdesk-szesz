function Test-MicrophoneStatus {
    [CmdletBinding()]
    param ()

    $microphones = Get-PnpDevice |
        Where-Object {
            $_.InstanceId -like 'SWD\MMDEVAPI*' -and
            $_.Class -eq 'AudioEndpoint'
        }

    if (-not $microphones) {
        return [PSCustomObject]@{
            Category = 'Audio'
            Name     = 'Microphone'
            Status   = 'Not Found'
            Detail   = 'Nenhum Microfone detectado no sistema.'
            Result   = 'ALERT'
        }
    }

    foreach ($mic in $microphones) {

        $alert   = $false
        $details = @()

        if ($mic.Status -ne 'OK') {
            $alert = $true
            $details += 'Dispositivo desabilitado'
        }

        if ($mic.FriendlyName -match 'Realtek|USB|Micro') {
            $details += 'Dispositivo de captura detectado'
        }

        [PSCustomObject]@{
            Category = 'Audio'
            Name     = $mic.FriendlyName
            Status   = $mic.Status
            Detail   = ($details -join '; ')
            Result   = if ($alert) { 'ALERT' } else { 'OK' }
        }
    }
}
