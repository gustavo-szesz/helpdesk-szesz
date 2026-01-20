function Export-ApiIp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ApiUrl = "https://localhost:7215/api/get-ip",

        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck
    )

    try {
        $ipData = Get-IPConfigurationJson
        $jsonPayload = $ipData | ConvertTo-Json -Depth 5

        Write-Verbose "Enviando dados para: $ApiUrl"
        $invokeParams = @{
            Uri            = $ApiUrl
            Method         = 'Post'
            Body           = $jsonPayload
            ContentType    = 'application/json'
            ErrorAction    = 'Stop'
        }

        if ($SkipCertificateCheck) {
            $invokeParams['SkipCertificateCheck'] = $true
        }

        $response = Invoke-RestMethod @invokeParams
        return $response
    }
    catch {
        Write-Error "Erro ao enviar dados para a API: $_"
        return $null
        }
    
}