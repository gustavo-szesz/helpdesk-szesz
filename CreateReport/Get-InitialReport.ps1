function Get-InitialReport {
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
        #$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        #$Path = Join-Path $env:TEMP "report-poupa-tempo\IPConfig_${computerName}_${timestamp}.html"
        #$directory = Split-Path -Path $Path -Parent
        #if (-not (Test-Path -Path $directory)) {
        #    New-Item -Path $directory -ItemType Directory | Out-Null
        #}
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $Path = Join-Path "C:\Users\gustavo.szesz\OneDrive - SHOPCIDADAO\Documentos\Reports" "IPConfig_${computerName}_${timestamp}.html"
        $directory = Split-Path -Path $Path -Parent
        if (-not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory | Out-Null
        }
    }

    # Coleta os dados
    Write-Verbose "Coletando informações do sistema..."
    $reportData = Get-ImportantInfo

    # Separa por categoria
    $systemInfo = $reportData | Where-Object { $_.Category -eq 'SystemInfo' }
    $networkInfo = $reportData | Where-Object { $_.Category -eq 'Network' } 
    $memoryInfo = $reportData | Where-Object { $_.Category -eq 'MemoryInfo' }
    $diskInfo = $reportData | Where-Object { $_.Category -eq 'DiskInfo' }
    $cleanupInfo = $reportData | Where-Object { $_.Category -eq 'CleanupInfo' }
    $topProcessesInfo = $reportData | Where-Object { $_.Category -eq 'TopProcess' }

    # Carrega o template
    $templatePath = Join-Path $PSScriptRoot "..\report-template.html"
    $cssPath = Join-Path $PSScriptRoot "..\report-styles.css"

    if (-not (Test-Path $templatePath)) {
        Write-Error "Template não encontrado em: $templatePath"
        return
    }

    $template = Get-Content $templatePath -Raw

    # Copia CSS para o mesmo diretório do HTML
    if (Test-Path $cssPath) {
        $cssDestination = Join-Path (Split-Path -Path $Path -Parent) "report-styles.css"
        Copy-Item -Path $cssPath -Destination $cssDestination -Force
    } else {
        Write-Warning "CSS não encontrado em: $cssPath"
    }

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
            <span class="info-label">Usuário Atual</span>
            <span class="info-value">$($systemInfo.CurrentUser)</span>
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
    
    # HTML para NetworkInfo (Tabela)
    $networkInfoHtml = $networkInfo | ConvertTo-Html -Fragment -Property Name, IPv4Address, IPv6Address, DefaultGateway, DNSAddresses, Result
    
    # HTML para MemoryInfo (Tabela)
    $memoryInfoHtml = $memoryInfo | ConvertTo-Html -Fragment -Property TotalRAM, FreeRAM, UsedRAM, Result
    
    # HTML para DiskInfo (Tabela)
    $diskInfoHtml = $diskInfo | ConvertTo-Html -Fragment -Property Drive, Label, FileSystem, TotalSize, UsedSpace, FreeSpace, UsedPercent, HealthStatus, Result

    # top process de memoria
    $topProcessesInfo = $reportData | Where-Object { $_.Category -eq 'TopProcess' }
    $topProcessesHtml = $topProcessesInfo | ConvertTo-Html -Fragment -Property ProcessName, Instances, TotalMemoryMB, Company

     # HTML para CleanupInfo (Tabela)
    $cleanupInfoHtml = $cleanupInfo | ConvertTo-Html -Fragment -Property Location, Path, SizeGB, FileCount, Result

    # HTML para TopProcesses (Tabela)
    $topProcessesHtml = $topProcessesInfo | ConvertTo-Html -Fragment -Property ProcessName, Instances, TotalMemoryMB, Company

    # Substitui os placeholders no template
    $html = $template
    $html = $html -replace '{{REPORT_TITLE}}', 'Relatório de Configuração de Rede'
    $html = $html -replace '{{LOGO_URL}}', 'https://raw.githubusercontent.com/gustavo-szesz/helpdesk-szesz/refs/heads/main/Assets/poupa-tempo-pr.png'
    $html = $html -replace '{{SYSTEM_INFO}}', $systemInfoHtml
    $html = $html -replace '{{NETWORK_INFO}}', $networkInfoHtml
    $html = $html -replace '{{MEMORY_INFO}}', $memoryInfoHtml
    $html = $html -replace '{{TOP_MEMORY_PROCESSES}}', $topProcessesHtml
    $html = $html -replace '{{DISK_INFO}}', $diskInfoHtml
    $html = $html -replace '{{CLEANUP_INFO}}', $cleanupInfoHtml
    $html = $html -replace '{{TIMESTAMP}}', (Get-Date -Format 'dd/MM/yyyy HH:mm:ss')

    # Salva o arquivo
    $html | Out-File -FilePath $Path -Encoding UTF8

    Write-Host "Relatório gerado com sucesso!" -ForegroundColor Green
    Write-Host "Arquivo: $Path" -ForegroundColor Cyan
    
    # Abre no navegador se solicitado
    if ($Open) {
        Invoke-Item $Path
    }

    # Retorna o caminho do arquivo gerado
    return $Path
}
