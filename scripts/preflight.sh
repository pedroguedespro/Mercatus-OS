#!/usr/bin/env bash
# Preflight — rode ANTES do /setup
#
# Fica fora do Claude Code de proposito. Se ele morasse dentro de uma skill,
# nao conseguiria detectar o problema mais chato: voce ja ter um /setup de
# outro sistema instalado, que venceria o nosso e rodaria no lugar dele.
#
# Uso:  bash scripts/preflight.sh

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

PROB=0; AVISO=0
erro()  { echo "  [X] $*"; PROB=$((PROB+1)); }
aviso() { echo "  [!] $*"; AVISO=$((AVISO+1)); }
ok()    { echo "  [ok] $*"; }

echo "=================================================="
echo " Preflight — Mercatus OS"
echo "=================================================="

echo
echo "[1] Voce esta na pasta certa?"
FALTA=""
for f in CLAUDE.md .claude/skills/setup/SKILL.md .gitignore; do
  [ -e "$f" ] || FALTA="$FALTA $f"
done
if [ -n "$FALTA" ]; then
  erro "nao parece a raiz do Mercatus OS. Faltando:$FALTA"
  echo "       Entre na pasta que voce clonou e rode de novo."
else
  ok "raiz do Mercatus OS ($(pwd))"
fi

echo
echo "[2] Os programas necessarios estao instalados?"
for p in git bash; do
  if command -v "$p" >/dev/null 2>&1; then ok "$p ($(command -v "$p"))"; else erro "$p nao encontrado"; fi
done
if command -v claude >/dev/null 2>&1; then ok "claude"; else
  erro "claude nao encontrado — instale o Claude Code antes de continuar"
fi

echo
echo "[3] A protecao contra commit de credencial esta ligada?"
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  erro "isto nao e um repositorio git. Rode: git init"
else
  HP=$(git config core.hooksPath 2>/dev/null)
  if [ "$HP" = ".githooks" ]; then ok "core.hooksPath = .githooks"
  else
    erro "core.hooksPath nao aponta pra .githooks (esta: '${HP:-vazio}')"
    echo "       Corrija com:  git config core.hooksPath .githooks"
  fi
  [ -x .githooks/pre-commit ] && ok "hook de pre-commit executavel" || erro ".githooks/pre-commit ausente ou sem permissao"
  [ -f .claude/scripts/scanner-segredo.sh ] && ok "scanner presente" || erro "scanner ausente"
  git check-ignore -q "inbox/importacao/x" 2>/dev/null && ok "inbox/importacao/ fora do git" || aviso "inbox/importacao/ NAO esta sendo ignorado"
  git check-ignore -q ".env.example" 2>/dev/null && aviso ".env.example bloqueado (deveria passar)" || ok ".env.example liberado"
fi

echo
echo "[4] Ja existe um /setup de outro sistema na sua maquina?"
# Skill pessoal vence skill de projeto, e skill vence comando. Se a pessoa ja
# tem um /setup global, o DELA roda no lugar do nosso e nada funciona como
# esperado — sem mensagem de erro nenhuma.
COL=0
for n in setup iniciar syncar mapear atualizar novo-projeto; do
  for p in "$HOME/.claude/skills/$n" "$HOME/.claude/commands/$n.md"; do
    if [ -e "$p" ]; then
      if [ "$n" = "setup" ]; then erro "COLISAO: ja existe /$n em $p"; else aviso "colisao: /$n em $p"; fi
      COL=$((COL+1))
    fi
  done
done
[ "$COL" -eq 0 ] && ok "nenhuma colisao"

echo
echo "[5] Ja rodou setup aqui antes?"
if [ -f ".mercatus/setup-state.json" ]; then
  aviso "existe estado de setup anterior nesta pasta"
else
  ok "instalacao nova"
fi

echo
echo "[6] Pra onde este repositorio enviaria seu trabalho?"
if ! git remote get-url origin >/dev/null 2>&1; then
  ok "sem remote — voce trabalha local, sem backup na nuvem (da pra conectar depois com /syncar)"
else
  U=$(git remote get-url origin 2>/dev/null); P=$(git remote get-url --push origin 2>/dev/null)
  echo "      fetch: $U"
  echo "      push:  $P"
  [ "$U" != "$P" ] && aviso "fetch e push apontam pra lugares DIFERENTES — confira antes de enviar qualquer coisa"
  case "$U" in
    *Mercatus-OS*|*mercatus-os*|*ccos-ratos*)
      # Esta pasta pode ser a COPIA DE MANUTENCAO (Pedro e os socios editam o
      # produto aqui dentro) ou a instalacao de alguem que clonou direto. Nos
      # dois casos o origin e o mesmo; o que muda e a intencao. O marcador
      # .mercatus-mantenedor e gitignorado, entao nunca chega em quem instala.
      if [ -f ".mercatus-mantenedor" ]; then
        ok "origin e o repositorio do produto, e esta e a copia de manutencao"
      else
        erro "origin aponta pro repositorio DO PRODUTO, nao pro seu"
        echo "       Seu trabalho tentaria ir pro lugar errado. Corrija com:"
        echo "         git remote rename origin upstream"
        echo "         git branch --unset-upstream"
      fi ;;
    *) ok "origin nao e o repositorio do produto" ;;
  esac
fi

echo
echo "=================================================="
if [ "$PROB" -eq 0 ]; then
  echo " TUDO CERTO — pode abrir o Claude Code aqui e rodar /setup"
  [ "$AVISO" -gt 0 ] && echo " ($AVISO aviso(s) acima: nao impedem, mas vale ler)"
  exit 0
else
  echo " $PROB PROBLEMA(S) — resolva antes de rodar /setup"
  echo " Cada [X] acima diz o que fazer. Se travar, chame quem te passou isto."
  exit 1
fi
