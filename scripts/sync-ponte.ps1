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
    # NUNCA apagar pasta que nao foi esta ponte que criou.
    if (Test-Path (Join-Path $ponte ".ponte-gerada")) {
        Write-Host "aviso: substituindo copia antiga gerada por esta ponte"
        Remove-Item $ponte -Recurse -Force
    } else {
        Write-Host "PAREI: $ponte ja existe e NAO foi criada por este script."
        Write-Host "       Pode ter skills suas dentro. Nao vou apagar nada."
        Write-Host "       Mova ou renomeie a pasta e rode de novo."
        exit 1
    }
}

try {
    New-Item -ItemType Junction -Path $ponte -Target (Resolve-Path $origem) | Out-Null
    Write-Host "ok: ponte criada ($ponte -> $origem)"
} catch {
    Write-Host "aviso: nao consegui criar junction. Caindo pra copia."
    Write-Host "       ATENCAO: copia NAO se atualiza sozinha. Rode este script"
    Write-Host "       de novo sempre que mexer em $origem."
    Copy-Item $origem $ponte -Recurse
    New-Item -ItemType File (Join-Path $ponte ".ponte-gerada") -Force | Out-Null
    Write-Host "ok: copia feita"
}
