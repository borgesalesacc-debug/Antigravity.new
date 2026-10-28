---
name: ambiente-automacao
description: Diagnostica, valida e repara dependências de ambiente (Node.js, NPM, NPX e variáveis de ambiente como GITHUB_PAT) de forma autônoma para suporte a servidores MCP e automações.
---

# Skill: Automação e Resiliência de Ambiente

## Propósito
Garantir que o ambiente de execução do host possua todos os pré-requisitos necessários para a execução estável de servidores MCP (locais e remotos), hooks e automações do Antigravity, eliminando bloqueios por falta de binários ou variáveis de ambiente.

## Runbook de Diagnóstico e Reparação

### 1. Diagnóstico de Ambiente
Sempre que um servidor MCP stdio falhar ou uma ferramenta de linha de comando não for localizada:
1. Execute o script de diagnóstico automatizado:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".agents\scripts\check_env.ps1"
   ```
2. Inspecione a saída gerada em `.agents/docs/14_diagnostico_script.md`.
3. Verifique se o Node.js (v22+ LTS) e o NPX estão acessíveis no PATH do processo.

### 2. Correção de Runtime (Node.js)
Caso o Node.js esteja ausente ou desatualizado:
1. Execute o script resiliente com lógica de retry e fallback:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".agents\scripts\install_node.ps1"
   ```
2. O script avalia a instalação global via `winget` e, em caso de bloqueio por falta de privilégios de Administrador, ativa a contingência portátil baixando o pacote oficial para `.agents/tools/node/` e injetando no PATH da sessão.

### 3. Configuração de Credenciais Seguras
Caso a variável `GITHUB_PAT` não esteja presente:
1. **Nunca** grave tokens de autenticação diretamente em arquivos versionados do repositório (`.agents/mcp_config.json`).
2. Oriente o desenvolvedor a executar o utilitário protegido:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".agents\scripts\set_github_pat.ps1"
   ```
3. O token deve ser persistido apenas no escopo de usuário do Windows (`[System.Environment]::SetEnvironmentVariable('GITHUB_PAT', ..., 'User')`) ou referenciado via `${GITHUB_PAT}` no arquivo global `~/.gemini/config/mcp_config.json`.

### 4. Recarga do Antigravity
Após qualquer alteração em variáveis de ambiente globais ou instalação de softwares que alterem o PATH:
1. Solicite o recarregamento da janela (`Developer: Reload Window` no IDE) ou reinicialização do aplicativo Antigravity.
2. Inspecione o painel **Additional Options (...) > MCP Servers** para confirmar os indicadores verdes de conexão.
