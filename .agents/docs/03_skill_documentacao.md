# Documentação de Criação: Skill `documentacao-processo`

## Finalidade da Skill
A skill `documentacao-processo` estabelece um padrão repetível e auditável de governança técnica para o workspace. Ela instrui o agente e os desenvolvedores a catalogarem todas as alterações em MCPs, regras, hooks e habilidades do Antigravity, mantendo rastreabilidade histórica e controle de segurança.

## Estrutura Criada
* **Diretório da Skill**: [`.agents/skills/documentacao-processo/`](file:///j:/antigravity%20projetos/projeto%20prompt%20engine/.agents/skills/documentacao-processo/)
* **Arquivo Principal**: [`SKILL.md`](file:///j:/antigravity%20projetos/projeto%20prompt%20engine/.agents/skills/documentacao-processo/SKILL.md)

### Conteúdo do `SKILL.md`
```markdown
---
name: documentacao-processo
description: Registra e organiza a documentação de configuração de MCPs e automações no projeto.
trigger: manual
---

# Skill: Documentação de Processo

## Propósito
Manter um histórico estruturado das configurações de MCP, Skills e Hooks aplicadas ao projeto, garantindo rastreabilidade e reprodutibilidade.

## Instruções
1. Sempre que uma nova configuração for aplicada, crie um arquivo numerado em `.agents/docs/`.
2. Atualize o índice `00_INDICE.md` com o link e a data.
3. Inclua: comando executado, saída obtida, arquivo modificado e observações de segurança.
```

## Conformidade com a Arquitetura do Antigravity
* **Frontmatter YAML**: Contém as tags obrigatórias `name` e `description`, além do `trigger: manual` para ativação sob demanda.
* **Descoberta Automática**: Conforme a especificação do sistema de customizações do Antigravity, qualquer skill localizada em `.agents/skills/<nome>/SKILL.md` dentro da árvore do workspace é indexada automaticamente pelo Language Server através do mecanismo de *progressive disclosure*.
