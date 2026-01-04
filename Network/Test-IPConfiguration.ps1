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

function Export-IPConfigurationReport {
        <#
    .SYNOPSIS
    Exporta relatório de configuração de rede em HTML
    
    .DESCRIPTION
    Gera um relatório HTML completo com informações do sistema e adaptadores de rede
    
    .PARAMETER Path
    Caminho onde o arquivo HTML será salvo. Se não especificado, salva em %TEMP%\report-poupa-tempo\
    
    .PARAMETER Open
    Abre automaticamente o relatório no navegador após gerar
    
    .EXAMPLE
    Export-IPConfigurationReport
    Gera relatório na pasta temporária
    
    .EXAMPLE
    Export-IPConfigurationReport -Open
    Gera e abre o relatório automaticamente
    
    .EXAMPLE
    Export-IPConfigurationReport -Path "C:\Relatorios\cliente.html" -Open
    Salva em local específico e abre
    #>
    [CmdletBinding()]
    param (
        [string]$Path,
        [switch]$Open
    )

    # definir caminho como %temp%/report-poupa-tempo/ e criar o diretório se não existir
    if (-not $Path) {
        $computerName = $env:COMPUTERNAME
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $Path = Join-Path $env:TEMP "report-poupa-tempo\IPConfig_${computerName}_${timestamp}.html"
        $directory = Split-Path -Path $Path -Parent
        if (-not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory | Out-Null
        }
    }

    # Coleta os dados
    Write-Verbose "Coletando informações do sistema..."
    $reportData = Get-IPConfigurationReport

    # Separa SystemInfo e Network
    $systemInfo = $reportData | Where-Object { $_.Category -eq 'SystemInfo' }
    $networkInfo = $reportData | Where-Object { $_.Category -eq 'Network' } 

    $templatePath = Join-Path $PSScriptRoot "..\report-template.html"

    if (-not (Test-Path $templatePath)) {
        Write-Error "Template não encontrado em: $templatePath"
        return
    }

    $template = Get-Content $templatePath -Raw

    # Gera HTML para SystemInfo 
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
    # HTML para NetworkInfo
    $networkInfoHtml = $networkInfo | ConvertTo-Html -Fragment -Property Name, IPv4Address, IPv6Address, DefaultGateway, DNSAddresses, Result

    # replace placeholders
    $html = $template
    $html = $html -replace '{{REPORT_TITLE}}', 'Relatório de Configuração de Rede'
    $html = $html -replace '{{LOGO_URL}}', 'https://raw.githubusercontent.com/gustavo-szesz/helpdesk-szesz/refs/heads/main/Assets/poupa-tempo-pr.png'
    $html = $html -replace '{{SYSTEM_INFO}}', $systemInfoHtml
    $html = $html -replace '{{NETWORK_INFO}}', $networkInfoHtml
    $html = $html -replace '{{TIMESTAMP}}', (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')

    # Salvar
    $html | Out-File -FilePath $Path -Encoding UTF8

    Write-Host "✅ Relatório gerado com sucesso!" -ForegroundColor Green
    Write-Host "📄 Arquivo: $Path" -ForegroundColor Cyan
    
    # abrir
    if ($Open) {
        Invoke-Item $Path
    }

    return $Path
}