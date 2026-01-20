# Helpdesk Szesz 

Projeto criado para ter comandos úteis para suporte técnico do N1 a N2|N3

Link de acesso: https://encurtador.com.br/pMXQ

## Instalação e Configuração

### Importar o Módulo

```powershell
# Importar o módulo
Import-Module .\HelpdeskSzesz.psm1 -Force
```

## Comandos Principais

### Relatório Inicial (Get-InitialReport)

Gera um relatório HTML completo com informações do sistema, rede, memória, disco e processos.

#### Uso Básico

```powershell
# Gerar relatório na pasta temporária
Get-InitialReport

# Gerar e abrir automaticamente no navegador
Get-InitialReport -Open

# Salvar em local específico
Get-InitialReport -Path "C:\Relatorios\cliente.html"

# Salvar em local específico e abrir
Get-InitialReport -Path "C:\Relatorios\cliente.html" -Open
```

#### Onde o Relatório é Salvo?

Por padrão, o relatório é salvo em:
```
%TEMP%\report-poupa-tempo\IPConfig_<COMPUTERNAME>_<TIMESTAMP>.html
```

Exemplo: `C:\Users\gusta\AppData\Local\Temp\report-poupa-tempo\IPConfig_DESKTOP-D1KA26S_20260104_175146.html`

## Outros Comandos Disponíveis

### Informações do Sistema

```powershell
# Informações completas (todas as categorias)
Get-ImportantInfo

# Informações do sistema operacional
Get-SystemInfo

# Informações de memória
Get-MemoryInfo

# Informações de disco
Get-DiskInfo

# Configuração de rede
Get-IPConfiguration
```

### Testes de Rede

```powershell
# Testar conectividade com o gateway
Test-GatewayConnectivity
```

### Testes de Áudio

```powershell
# Testar status do microfone
Test-MicrophoneStatus

# Testar microfone padrão
Test-MicrophoneDefault
```

### Testes de Serviços

```powershell
# Verificar status de serviços
Test-ServiceStatus
```

## Estrutura do Projeto

```
exercism/
├── HelpdeskSzesz.psm1          # Módulo principal
├── README.md                    # Este arquivo
├── report-template.html         # Template HTML dos relatórios
├── report-styles.css            # Estilos CSS dos relatórios
├── Audio/                       # Scripts de teste de áudio
├── Core/                        # Scripts principais
├── CreateReport/                # Scripts de geração de relatórios
├── Info/                        # Scripts de coleta de informações
├── Network/                     # Scripts de testes de rede
└── Reports/                     # Relatórios gerados
```

## Dicas

1. **Use `-Open`** para visualizar o relatório imediatamente após a geração
2. **Relatórios ficam salvos** na pasta Reports ou em %TEMP%\report-poupa-tempo\
3. **Para reimportar o módulo** após alterações, use `Import-Module .\HelpdeskSzesz.psm1 -Force`
4. **Para ver todos os comandos disponíveis**: `Get-Command -Module HelpdeskSzesz`

## Exemplo de Fluxo de Trabalho

```powershell
# 1. Importar o módulo
Import-Module .\HelpdeskSzesz.psm1 -Force

# 2. Gerar relatório inicial
Get-InitialReport -Open

# 3. Fazer testes específicos se necessário
Test-GatewayConnectivity
Test-MicrophoneStatus

# 4. Coletar informações adicionais
Get-DiskInfo
Get-MemoryInfo
```

# 5. Convert to Json
Get-IPConfigurationJson | ConvertTo-Json -Depth 10 > .\example.json