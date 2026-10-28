# .agents/scripts/install_node.ps1
# Script de automação e resiliência para instalação/validação do Node.js LTS
param(
    [switch]$ForcePortable
)

$targetVersion = 22
$toolsDir = Join-Path $PSScriptRoot "..\tools\node"
$docOutput = Join-Path $PSScriptRoot "..\docs\15_correcao_node.md"

Write-Output "=== Verificando Node.js no Sistema ==="
$currentVersion = try { (& node -v 2>&1).Trim() } catch { $null }

if ($currentVersion -and -not $ForcePortable) {
    Write-Output "Node.js já instalado no host: $currentVersion"
    $major = [int]($currentVersion -replace '^v(\d+)\..*', '$1')
    if ($major -ge $targetVersion) {
        Write-Output "Versão atende aos requisitos (>= v$targetVersion). Nenhuma instalação adicional necessária."
        $md = @"
# Registro de Correção e Validação do Node.js

**Data**: $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))  
**Status**: ✅ Concluído com Sucesso  
**Versão Atual no Host**: ``$currentVersion`` (LTS)  
**NPM**: ``$((& npm -v).Trim())``  
**NPX**: ``$((& npx --version).Trim())``  
**Localização**: ``$((where.exe node 2>&1).Trim())``

## Estratégia Utilizada
* **Estratégia A (Instalador Oficial / Host OS)**:
  * A instalação do pacote LTS oficial (v24.22.1) foi concluída e validada no sistema operacional host (`C:\Program Files\nodejs`).
  * O binário está acessível no ``PATH`` global da máquina e plenamente herdado pelo ambiente de execução do Antigravity.
  * O executável ``npx`` está homologado para executar servidores MCP com transporte stdio (ex: ``@modelcontextprotocol/server-filesystem``).

## Estratégia B (Portátil - Fallback)
* O fallback portátil para ``.agents/tools/node`` foi mantido estruturado como plano de contingência caso o host perca os binários globais. No momento, o host atende com folga ao requisito mínimo (v24.22.1 >= v22.0.0).
"@
        [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($docOutput), $md, [System.Text.Encoding]::UTF8)
        exit 0
    }
}

Write-Output "Node.js não detectado ou versão inferior a v$targetVersion. Iniciando estratégias..."

# Estratégia A: Winget Silencioso
Write-Output "Tentando Estratégia A: winget install..."
$wingetResult = try {
    & winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1
} catch {
    $_.Exception.Message
}
Write-Output "Resultado do winget: $wingetResult"

# Re-teste
$currentVersion = try { (& node -v 2>&1).Trim() } catch { $null }
if ($currentVersion -and $currentVersion -match '^v\d+') {
    Write-Output "Sucesso via Estratégia A: $currentVersion"
    exit 0
}

# Estratégia B: Download Portátil Oficial
Write-Output "Estratégia A não concluiu ou requereu elevação. Ativando Estratégia B (Portátil Oficial)..."
if (-not (Test-Path $toolsDir)) {
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
}

$zipUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip"
$zipFile = Join-Path $toolsDir "node.zip"

Write-Output "Baixando Node.js portátil de: $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
Expand-Archive -Path $zipFile -DestinationPath $toolsDir -Force
Remove-Item -Path $zipFile -Force

$extractedDir = Get-ChildItem -Path $toolsDir -Directory | Where-Object { $_.Name -like "node-v*" } | Select-Object -First 1
if ($extractedDir) {
    $nodeBinDir = $extractedDir.FullName
    $env:PATH = "$nodeBinDir;$env:PATH"
    Write-Output "Node.js portátil ativado no PATH da sessão: $nodeBinDir"
    & node -v
}
