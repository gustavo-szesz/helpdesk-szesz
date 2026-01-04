function Export-IPConfigurationReport {
    <#
    .SYNOPSIS
    Exporta relatório de configuração de rede em formato HTML profissional.
    
    .DESCRIPTION
    Gera um relatório HTML usando o template base e injeta informações do sistema e rede.
    
    .PARAMETER Path
    Caminho onde o arquivo HTML será salvo. Se não especificado, usa nome automático com timestamp.
    
    .PARAMETER Open
    Se especificado, abre o relatório no navegador automaticamente após gerar.
    
    .EXAMPLE
    Export-IPConfigurationReport
    
    .EXAMPLE
    Export-IPConfigurationReport -Path "C:\Reports\network.html" -Open
    #>
    
    [CmdletBinding()]
    param (
        [string]$Path,
        [switch]$Open
    )
    
    # Define o caminho padrão se não especificado
    if (-not $Path) {
        $computerName = $env:COMPUTERNAME
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $Path = Join-Path $PSScriptRoot "..\Reports\IPConfig_${computerName}_${timestamp}.html"
    }
    
    # Cria diretório se não existir
    $directory = Split-Path $Path -Parent
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    # Coleta os dados
    Write-Verbose "Coletando informações do sistema..."
    $reportData = Get-IPConfigurationReport
    
    # Separa SystemInfo e Network
    $systemInfo = $reportData | Where-Object { $_.Category -eq 'SystemInfo' }
    $networkInfo = $reportData | Where-Object { $_.Category -eq 'Network' }
    
    # Carrega o template
    $templatePath = Join-Path $PSScriptRoot "..\report-template.html"
    
    if (-not (Test-Path $templatePath)) {
        Write-Error "Template não encontrado em: $templatePath"
        return
    }
    
    $template = Get-Content $templatePath -Raw
    
    # Gera HTML para SystemInfo (Card bonito)
    $systemInfoHtml = @"
<div class="system-info-card">
    <div class="info-grid">
        <div class="info-item">
            <span class="info-label">Computador</span>
            <span class="info-value">$($systemInfo.ComputerName)</span>
        </div>
        <div class="info-item">
            <span class="info-label">Domínio</span>
            <span class="info-value">$($systemInfo.Domain)</span>
        </div>
        <div class="info-item">
            <span class="info-label">Fabricante</span>
            <span class="info-value">$($systemInfo.Manufacturer)</span>
        </div>
        <div class="info-item">
            <span class="info-label">Modelo</span>
            <span class="info-value">$($systemInfo.Model)</span>
        </div>
        <div class="info-item">
            <span class="info-label">Número de Série</span>
            <span class="info-value">$($systemInfo.SerialNumber)</span>
        </div>
        <div class="info-item">
            <span class="info-label">Data da Verificação</span>
            <span class="info-value">$($systemInfo.Timestamp.ToString('dd/MM/yyyy HH:mm:ss'))</span>
        </div>
    </div>
</div>
"@
    
    # Gera HTML para NetworkInfo (Tabela)
    $networkInfoHtml = $networkInfo | ConvertTo-Html -Fragment -Property Name, IPv4Address, IPv6Address, DefaultGateway, DNSAddresses, Result
    
    # Substitui os placeholders no template
    $html = $template
    $html = $html -replace '{{REPORT_TITLE}}', 'Relatório de Configuração de Rede'
    $html = $html -replace '{{LOGO_URL}}', 'https://i.imgur.com/YourLogoHere.png'  # Você vai substituir depois
    $html = $html -replace '{{SYSTEM_INFO}}', $systemInfoHtml
    $html = $html -replace '{{NETWORK_INFO}}', $networkInfoHtml
    $html = $html -replace '{{TIMESTAMP}}', (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
    
    # Salva o arquivo
    $html | Out-File -FilePath $Path -Encoding UTF8
    
    Write-Host "✅ Relatório gerado com sucesso!" -ForegroundColor Green
    Write-Host "📄 Arquivo: $Path" -ForegroundColor Cyan
    
    # Abre no navegador se solicitado
    if ($Open) {
        Invoke-Item $Path
    }
    
    # Retorna o caminho do arquivo gerado
    return $Path
}
