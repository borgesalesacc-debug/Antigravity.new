# Documentação de Configuração: MCP Remoto (GitHub)

## Finalidade do Servidor
O servidor MCP `github` permite a integração remota com a API do GitHub (via endpoint MCP compatível), viabilizando operações como inspeção de repositórios, busca de código, visualização de pull requests, issues e leitura de documentações diretamente a partir do chat do Antigravity.

## Arquivo de Configuração e Gestão de Segredos
* **Caminho**: [`~/.gemini/config/mcp_config.json`](file:///C:/Users/User/.gemini/config/mcp_config.json) (global, fora do versionamento do repositório).
* **Escopo**: Máquina local (aplica-se a todas as sessões do Antigravity).
* **Prática de Segurança**: O token não foi gravado em texto plano no workspace (`.agents/mcp_config.json`) para prevenir vazamento acidental em commits de Git. Foi utilizado o arquivo de configuração global com referência de variável de ambiente `${GITHUB_PAT}`.

### Conteúdo Configurado
```json
{
  "mcpServers": {
    "github": {
      "serverUrl": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PAT}"
      }
    }
  }
}
```

## Validação da Sintaxe JSON
* **Comando executado**:
  ```powershell
  Get-Content -Raw "$HOME\.gemini\config\mcp_config.json" | ConvertFrom-Json | ConvertTo-Json -Depth 5
  ```
* **Saída da validação**:
  ```json
  {
      "mcpServers":  {
                         "github":  {
                                        "serverUrl":  "https://api.githubcopilot.com/mcp/",
                                        "headers":  {
                                                        "Authorization":  "Bearer ${GITHUB_PAT}"
                                                    }
                                    }
                     }
  }
  ```
* **Status da Validação**: Sucesso.

## Escopos Recomendados para o GitHub PAT
Para que o servidor MCP funcione adequadamente com repositórios e perfis, os seguintes escopos devem ser concedidos ao gerar o token no GitHub (Settings > Developer settings > Personal access tokens):

1. `repo`: Acesso total a repositórios privados e públicos (necessário para ler código, commits, issues e PRs).
2. `read:org`: Leitura de organizações e membros associados à conta.
3. `read:user`: Leitura dos dados de perfil do usuário autenticado.

> [!NOTE]
> No ambiente local atual, a variável de ambiente `GITHUB_PAT` não está definida (`Test-Path env:GITHUB_PAT` retornou `False`). Para ativar as chamadas autenticadas ao GitHub, defina a variável na sessão ou sistema operacional:
> ```powershell
> [System.Environment]::SetEnvironmentVariable('GITHUB_PAT', 'seu_token_aqui', 'User')
> ```
