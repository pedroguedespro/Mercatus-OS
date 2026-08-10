#!/usr/bin/env bash
# Ponte cross-IA — Mac e Linux
#
# O Codex procura skills em .agents/skills; o Claude Code, em .claude/skills.
# Em vez de manter duas pastas (que divergem na primeira edicao), liga uma
# na outra. A fonte e SEMPRE .claude/skills.
#
# Idempotente: pode rodar quantas vezes quiser.
# No Windows, use scripts\sync-ponte.ps1 (junction, sem precisar de admin).

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0")/.." 2>/dev/null || cd "$(dirname "$0")/.."

ORIGEM=".claude/skills"
PONTE=".agents/skills"

case "$(uname -s)" in
  MINGW*|CYGWIN*|MSYS*)
    echo "Windows detectado. Symlink aqui exige privilegio elevado."
    echo "Use:  powershell -File scripts\\sync-ponte.ps1"
    exit 1 ;;
esac

[ -d "$ORIGEM" ] || { echo "ERRO: $ORIGEM nao existe. Rode na raiz do repositorio."; exit 1; }

mkdir -p .agents

if [ -L "$PONTE" ]; then
  echo "ok: ponte ja existe ($PONTE -> $(readlink "$PONTE"))"
  exit 0
fi

if [ -d "$PONTE" ] && [ ! -L "$PONTE" ]; then
  echo "aviso: $PONTE e uma pasta de verdade, nao um link."
  echo "       Provavelmente sobrou de um fallback de copia."
  rm -rf "$PONTE"
fi

if ln -s "../$ORIGEM" "$PONTE" 2>/dev/null; then
  echo "ok: ponte criada ($PONTE -> ../$ORIGEM)"
else
  echo "aviso: nao consegui criar symlink. Caindo pra copia."
  echo "       ATENCAO: copia NAO se atualiza sozinha. Rode este script"
  echo "       de novo sempre que mexer em $ORIGEM."
  cp -r "$ORIGEM" "$PONTE"
  echo "ok: copia feita"
fi
