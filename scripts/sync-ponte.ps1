# Ponte cross-IA — Windows
#
# O Codex procura skills em .agents\skills; o Claude Code, em .claude\skills.
# Usa JUNCTION, que no Windows nao exige privilegio de administrador
# (symlink exige). A fonte e SEMPRE .claude\skills.
#
# Idempotente. Uso:  powershell -File scripts\sync-ponte.ps1

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$origem = ".claude\skills"
$ponte  = ".agents\skills"

if (-not (Test-Path $origem)) {
    Write-Host "ERRO: $origem nao existe. Rode na raiz do repositorio."
    exit 1
}

if (-not (Test-Path ".agents")) { New-Item -ItemType Directory ".agents" | Out-Null }

$item = Get-Item $ponte -ErrorAction SilentlyContinue
if ($null -ne $item) {
    if ($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink") {
        Write-Host "ok: ponte ja existe ($ponte -> $($item.Target))"
        exit 0
    }
    Write-Host "aviso: $ponte e uma pasta de verdade, nao um link."
    Write-Host "       Provavelmente sobrou de um fallback de copia."
    Remove-Item $ponte -Recurse -Force
}

try {
    New-Item -ItemType Junction -Path $ponte -Target (Resolve-Path $origem) | Out-Null
    Write-Host "ok: ponte criada ($ponte -> $origem)"
} catch {
    Write-Host "aviso: nao consegui criar junction. Caindo pra copia."
    Write-Host "       ATENCAO: copia NAO se atualiza sozinha. Rode este script"
    Write-Host "       de novo sempre que mexer em $origem."
    Copy-Item $origem $ponte -Recurse
    Write-Host "ok: copia feita"
}
