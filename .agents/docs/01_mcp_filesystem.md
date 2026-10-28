# Documentação de Configuração: MCP Local (Filesystem)

## Finalidade do Servidor
O servidor MCP `filesystem` (@modelcontextprotocol/server-filesystem) fornece acesso seguro e controlado para leitura e manipulação de arquivos dentro do escopo do diretório do workspace (`.`), permitindo ao modelo inspecionar, ler e analisar a estrutura de arquivos sem expor caminhos fora do repositório.

## Arquivo de Configuração
* **Caminho**: [`.agents/mcp_config.json`](file:///j:/antigravity%20projetos/projeto%20prompt%20engine/.agents/mcp_config.json)
* **Escopo**: Workspace local

### Conteúdo Configurado
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "."
      ]
    }
  }
}
```

## Validação da Sintaxe JSON
* **Comando executado**:
  ```powershell
  Get-Content -Raw ".agents\mcp_config.json" | ConvertFrom-Json | ConvertTo-Json -Depth 5
  ```
* **Saída da validação**:
  ```json
  {
      "mcpServers":  {
                         "filesystem":  {
                                            "command":  "npx",
                                            "args":  [
                                                         "-y",
                                                         "@modelcontextprotocol/server-filesystem",
                                                         "."
                                                     ]
                                        }
                     }
  }
  ```
* **Status da Validação**: Sucesso (JSON perfeitamente estruturado e em conformidade com o schema oficial de MCP).

## Observações do Ambiente
* O transporte configurado é `stdio`.
* Para execução do comando `npx` em tempo de execução pelo Antigravity Language Server, o ambiente do host requer que o binário do Node.js/NPM esteja devidamente registrado no PATH do sistema.
