# .agents/scripts/set_github_pat.ps1
# Script utilitário para o usuário configurar a variável GITHUB_PAT com segurança
param(
    [Parameter(Mandatory=$false)]
    [string]$Token
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    Configurador de Variável de Ambiente: GITHUB_PAT      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "Por favor, insira o seu Personal Access Token do GitHub (ghp_...):" -ForegroundColor Yellow
    $Token = Read-Host -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token)
    $Token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "[ERRO] Nenhum token informado. Operação cancelada." -ForegroundColor Red
    exit 1
}

# Configura no escopo de Usuário (persistente)
[System.Environment]::SetEnvironmentVariable('GITHUB_PAT', $Token, 'User')

# Configura na sessão atual
$env:GITHUB_PAT = $Token

# Validação e exibição mascarada
$saved = [System.Environment]::GetEnvironmentVariable('GITHUB_PAT', 'User')
if ($saved) {
    $masked = $saved.Substring(0, [Math]::Min(4, $saved.Length)) + "..." + $saved.Substring([Math]::Max(0, $saved.Length - 4))
    Write-Host "`n[SUCESSO] Variável GITHUB_PAT gravada com sucesso no escopo do Usuário!" -ForegroundColor Green
    Write-Host "Valor mascarado: $masked" -ForegroundColor Green
    Write-Host "Próximo passo: Reinicie o Antigravity para que o servidor MCP github passe a 'Conectado'." -ForegroundColor Cyan
    Write-Host "`n================================================================================" -ForegroundColor Yellow
    Write-Host " [AÇÃO NECESSÁRIA] Feche esta janela (ou digite 'exit') para continuar no agente." -ForegroundColor Yellow
    Write-Host "================================================================================" -ForegroundColor Yellow
} else {
    Write-Host "`n[FALHA] Não foi possível persistir a variável GITHUB_PAT." -ForegroundColor Red
}
