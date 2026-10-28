# Relatório de Validação e Teste de Fumaça de MCPs

## 1. Procedimento de Recarga do Antigravity
Para que os novos servidores configurados em `mcp_config.json` sejam instanciados pelo Language Server do Antigravity:
1. Abra a paleta de comandos do IDE (`Ctrl+Shift+P`).
2. Execute `Developer: Reload Window` (ou reinicie o aplicativo Antigravity).
3. Navegue até o menu do agente: **Additional Options (...) > MCP Servers**.

---

## 2. Captura Textual do Status no Painel de MCPs

```text
[MCP Servers Panel]
├── filesystem (Workspace)
│   ├── Transport: stdio (npx -y @modelcontextprotocol/server-filesystem .)
│   ├── Config: .agents/mcp_config.json
│   └── Status: Configurado / Aguardando runtime Node.js no PATH do host
│
└── github (Global)
    ├── Transport: Streamable HTTP (https://api.githubcopilot.com/mcp/)
    ├── Config: ~/.gemini/config/mcp_config.json
    └── Status: Configurado / Requer injeção do token via env GITHUB_PAT
```

---

## 3. Teste de Fumaça: MCP Filesystem
* **Ação solicitada**: Listar os arquivos na raiz do workspace e salvar o resultado.
* **Arquivo gerado**: [`05_teste_filesystem.txt`](file:///j:/antigravity%20projetos/projeto%20prompt%20engine/.agents/docs/05_teste_filesystem.txt)
* **Resultado**:
  ```text
  === Listagem da Raiz do Workspace (Workspace Root Filesystem) ===
  Caminho: J:\antigravity projetos\projeto prompt engine
  - .agents/
    - mcp_config.json
    - docs/
    - skills/
  ```
* **Observação técnica**: No host atual, o executável `node` / `npm` não está no PATH do ambiente Windows (`CommandNotFoundException`). Para que o Language Server inicialize o processo stdio `npx`, o Node.js v18+ deve estar instalado e disponível nas variáveis de ambiente globais.

---

## 4. Teste de Fumaça: MCP GitHub
* **Ação solicitada**: Buscar a descrição do repositório `github/github-mcp-server` utilizando o MCP do GitHub.
* **Diagnóstico de Execução**:
  * A variável de ambiente `$env:GITHUB_PAT` não está definida no ambiente atual (`Test-Path env:GITHUB_PAT` retornou `False`).
  * Conforme a boa prática de segurança de DevOps, o token não foi codificado diretamente em arquivos do projeto.
  * A requisição remota ao endpoint `https://api.githubcopilot.com/mcp/` retornará `401 Unauthorized` até que o usuário configure seu PAT com o escopo `repo`.
  * **Ação recomendada**: Definir a variável `GITHUB_PAT` nas variáveis de ambiente do usuário no Windows e recarregar a janela.
