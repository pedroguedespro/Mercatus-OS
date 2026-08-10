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
# git rev-parse ja devolve a RAIZ. Nao acrescentar /.. depois dela.
RAIZ="$(git rev-parse --show-toplevel 2>/dev/null)" || RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RAIZ" || { echo "ERRO: nao achei a raiz do repositorio"; exit 1; }

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
  # NUNCA apagar pasta que nao foi esta ponte que criou. Se o usuario tiver
  # skills proprias em .agents/skills, um rm -rf aqui destruiria o trabalho
  # dele em silencio. So removemos o que tem a nossa marca.
  if [ -f "$PONTE/.ponte-gerada" ]; then
    echo "aviso: substituindo copia antiga gerada por esta ponte"
    rm -rf "$PONTE"
  else
    echo "PAREI: $PONTE ja existe e NAO foi criada por este script."
    echo "       Pode ter skills suas dentro. Nao vou apagar nada."
    echo "       Mova ou renomeie a pasta e rode de novo."
    exit 1
  fi
fi

if ln -s "../$ORIGEM" "$PONTE" 2>/dev/null; then
  echo "ok: ponte criada ($PONTE -> ../$ORIGEM)"
else
  echo "aviso: nao consegui criar symlink. Caindo pra copia."
  echo "       ATENCAO: copia NAO se atualiza sozinha. Rode este script"
  echo "       de novo sempre que mexer em $ORIGEM."
  cp -r "$ORIGEM" "$PONTE"
  touch "$PONTE/.ponte-gerada"
  echo "ok: copia feita"
fi
