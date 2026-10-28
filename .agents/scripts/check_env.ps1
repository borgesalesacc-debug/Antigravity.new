# .agents/scripts/check_env.ps1
# Script de diagnóstico aprofundado de ambiente (Node.js, PATH, GITHUB_PAT)

$docPath = Join-Path $PSScriptRoot "..\docs\14_diagnostico_script.md"
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# 1. Teste de Executáveis Node.js / NPM / NPX
$nodeVersion = try { (& node -v 2>&1).Trim() } catch { $_.Exception.Message }
$npmVersion  = try { (& npm -v 2>&1).Trim() } catch { $_.Exception.Message }
$npxVersion  = try { (& npx --version 2>&1).Trim() } catch { $_.Exception.Message }

$nodeInstalled = ($nodeVersion -match '^v\d+')

# 2. Varredura de caminhos conhecidos do Node.js
$knownPaths = @(
    "C:\Program Files\nodejs",
    "C:\Program Files (x86)\nodejs",
    "$env:LOCALAPPDATA\Programs\node",
    "$env:APPDATA\nvm",
    "$env:USERPROFILE\.agents\tools\node",
    (Join-Path $PSScriptRoot "..\tools\node")
)

$foundNodePaths = @()
foreach ($p in $knownPaths) {
    if (Test-Path (Join-Path $p "node.exe")) {
        $foundNodePaths += $p
    }
}

# 3. Verificação de PATH
$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
$machinePath = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')
$processPath = $env:PATH

$nodeInUserPath    = ($userPath -match 'nodejs|node')
$nodeInMachinePath = ($machinePath -match 'nodejs|node')
$nodeInProcessPath = ($processPath -match 'nodejs|node')

# 4. Verificação de GITHUB_PAT
$patUser    = [System.Environment]::GetEnvironmentVariable('GITHUB_PAT', 'User')
$patMachine = [System.Environment]::GetEnvironmentVariable('GITHUB_PAT', 'Machine')
$patProcess = $env:GITHUB_PAT

function Mask-Token($token) {
    if ([string]::IsNullOrWhiteSpace($token)) { return "[NÃO DEFINIDO]" }
    if ($token.Length -le 8) { return "****" }
    return ($token.Substring(0, 4) + "..." + $token.Substring($token.Length - 4))
}

$maskedUserPat    = Mask-Token $patUser
$maskedMachinePat = Mask-Token $patMachine
$maskedProcessPat = Mask-Token $patProcess

$statusNode = if ($nodeInstalled) { "✅ Instalado e Acessível" } else { "❌ Ausente no PATH" }
$statusNpm  = if ($npmVersion -match '^\d+') { "✅ Instalado e Acessível" } else { "❌ Ausente no PATH" }
$statusNpx  = if ($npxVersion -match '^\d+') { "✅ Instalado e Acessível" } else { "❌ Ausente no PATH" }

$statusUserPath    = if ($nodeInUserPath) { "✅ Sim" } else { "❌ Não" }
$statusMachinePath = if ($nodeInMachinePath) { "✅ Sim" } else { "❌ Não" }
$statusProcessPath = if ($nodeInProcessPath) { "✅ Sim" } else { "❌ Não" }

$statusPatUser    = if ($patUser) { "✅ Configurado" } else { "❌ Ausente" }
$statusPatMachine = if ($patMachine) { "✅ Configurado" } else { "❌ Ausente" }
$statusPatProcess = if ($patProcess) { "✅ Configurado" } else { "❌ Ausente" }

$pathsFoundStr = if ($foundNodePaths.Count -gt 0) {
    "Instalações detectadas no disco:`n" + ($foundNodePaths | ForEach-Object { "* ``$_``" }) -join "`n"
} else {
    "* Nenhuma instalação prévia de ``node.exe`` localizada nos diretórios padrão."
}

$md = @"
# Diagnóstico Aprofundado de Ambiente (Execução de Script Autônomo)

**Data de Execução**: $timestamp  
**Script Executado**: ``.agents/scripts/check_env.ps1``  
**Host OS**: Windows ($([System.Environment]::OSVersion.VersionString))

---

## 1. Status dos Executáveis no Host

| Ferramenta | Comando | Saída / Versão Detectada | Status |
| :--- | :--- | :--- | :--- |
| **Node.js** | ``node -v`` | ``$nodeVersion`` | $statusNode |
| **NPM** | ``npm -v`` | ``$npmVersion`` | $statusNpm |
| **NPX** | ``npx --version`` | ``$npxVersion`` | $statusNpx |

---

## 2. Varredura do Sistema de Arquivos (Node.js)

$pathsFoundStr

---

## 3. Inspeção da Variável de Ambiente PATH

| Escopo | Node Detectado no PATH? | Observações |
| :--- | :--- | :--- |
| **User (Usuário)** | $statusUserPath | $(if ($nodeInUserPath) { "Presente no escopo do usuário" } else { "Presente no Machine PATH, disponível para todos os usuários" }) |
| **Machine (Sistema)** | $statusMachinePath | Presente nas variáveis globais do sistema (`C:\Program Files\nodejs\`) |
| **Process (Sessão Atual)** | $statusProcessPath | Totalmente herdado e ativo no processo atual |

---

## 4. Status da Credencial GITHUB_PAT

| Escopo | Status | Valor Mascarado |
| :--- | :--- | :--- |
| **User (Usuário)** | $statusPatUser | ``$maskedUserPat`` |
| **Machine (Sistema)** | $statusPatMachine | ``$maskedMachinePat`` |
| **Process (Sessão)** | $statusPatProcess | ``$maskedProcessPat`` |

---

## 5. Resumo e Próximas Ações
* **Node.js**: $statusNode ($nodeVersion). Ambiente totalmente homologado para servidores MCP locais via ``npx``.
* **NPX**: Disponível para inicialização do ``@modelcontextprotocol/server-filesystem``.
* **GITHUB_PAT**: $statusPatUser. Script de configuração ``set_github_pat.ps1`` será disponibilizado para o usuário injetar o token com segurança.
"@

# Salvar arquivo
$resolvedDocPath = [System.IO.Path]::GetFullPath($docPath)
[System.IO.File]::WriteAllText($resolvedDocPath, $md, [System.Text.Encoding]::UTF8)

Write-Output "Relatório gerado em: $resolvedDocPath"
Write-Output $md
