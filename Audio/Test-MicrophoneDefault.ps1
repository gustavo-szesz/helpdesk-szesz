function Test-MicrophoneDefault {
    [CmdletBinding()]
    param ()

    # Validação do modo de execução
    if ($host.Runspace.ApartmentState -ne 'STA') {
        return [PSCustomObject]@{
            Category = 'Audio'
            Name     = 'Default Microphone'
            Status   = 'Unsupported Context'
            Detail   = 'PowerShell não está em modo STA'
            Result   = 'ALERT'
        }
    }

    try {
        $deviceEnumerator = New-Object -ComObject MMDeviceEnumerator
        $defaultMic = $deviceEnumerator.GetDefaultAudioEndpoint(1, 0)
    }
    catch {
        return [PSCustomObject]@{
            Category = 'Audio'
            Name     = 'Default Microphone'
            Status   = 'Access Failed'
            Detail   = 'Core Audio API indisponível'
            Result   = 'ALERT'
        }
    }

    [PSCustomObject]@{
        Category = 'Audio'
        Name     = $defaultMic.FriendlyName
        Status   = 'Configured'
        Detail   = 'Microfone padrão do sistema'
        Result   = 'OK'
    }
}
