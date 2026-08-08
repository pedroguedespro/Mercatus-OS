#!/usr/bin/env bash
# Scanner de segredo — roda antes de todo commit do /syncar
#
# Opera SOBRE OS ARQUIVOS STAGED, nunca sobre a pasta inteira. Isso e proposital:
#
#   - inbox/importacao/ e ignorado pelo git, entao material cru nunca chega aqui.
#     Isso nao e o scanner trabalhando — e o arquivo nao sendo candidato a commit.
#   - O caso que o scanner existe pra pegar e a pessoa PROMOVER um arquivo de la
#     pra uma area versionada sem perceber que tem credencial dentro.
#
# Se escaneasse a pasta toda, travaria todo /syncar enquanto houvesse qualquer
# importacao crua parada — e a pessoa aprenderia a ignorar o aviso.
#
# Uso:   bash .claude/scripts/scanner-segredo.sh
# Sai 0 se limpo, 1 se achou. O /syncar ABORTA o commit no 1.

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "nao e um repositorio git"; exit 0; }

ACHADOS=0
reportar() { echo "  [$1] $2"; ACHADOS=$((ACHADOS+1)); }

STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
if [ -z "$STAGED" ]; then
  echo "Nada staged pra escanear."
  exit 0
fi

N=$(echo "$STAGED" | wc -l)
echo "Escaneando $N arquivo(s) staged..."
echo

# ---------------------------------------------------------------------------
# 0. Repositorio git aninhado (gitlink) — comportamento verificado em 07/08/2026
# ---------------------------------------------------------------------------
# Skill instalada por `git clone` traz `.git/` propria. O `git add -A` entao
# NAO versiona os arquivos dela: cria um gitlink (modo 160000), que e so um
# ponteiro. Quem reclona recebe a pasta VAZIA e perde a ferramenta.
# O git avisa ("Clones of the outer repository will not contain the contents
# of the embedded repository"), mas o aviso passa batido no meio do output.
while IFS= read -r gl; do
  [ -z "$gl" ] && continue
  reportar "GITLINK" "$gl — repositorio git aninhado; os arquivos NAO seriam versionados"
done < <(git diff --cached --raw 2>/dev/null | awk '$2=="160000"{print $NF}')

if [ "$ACHADOS" -gt 0 ]; then
  echo
  echo "  Como resolver:"
  echo "    git rm --cached <pasta>"
  echo "    rm -rf <pasta>/.git     # solta a skill do repositorio de origem"
  echo "    git add <pasta>         # agora os arquivos entram de verdade"
  echo
  echo "  Instalar skill com 'git clone' sempre deixa .git/ pra tras. Use:"
  echo "    git clone --depth 1 <url> <destino> && rm -rf <destino>/.git"
  echo
fi

while IFS= read -r f; do
  [ -f "$f" ] || continue

  # --- 1. Arquivo que nao deveria estar staged, pelo nome -------------------
  case "$f" in
    *.env|*.env.[!e]*|.env)
      case "$f" in *.env.example) ;; *) reportar "ARQUIVO" "$f — arquivo .env real staged";; esac ;;
    *.pem|*.key|*.pfx|*.p12|*.cer|*.crt)
      reportar "ARQUIVO" "$f — chave ou certificado staged" ;;
    *service-account*.json|*credentials*.json|*client_secret*.json)
      reportar "ARQUIVO" "$f — arquivo de credencial de servico staged" ;;
  esac

  # --- 2. contas.yaml preenchido fora de templates/ -------------------------
  case "$f" in
    templates/*) ;;
    *contas.yaml)
      if grep -qE "^\s+-\s+nome:\s*\S" "$f" 2>/dev/null; then
        reportar "DADO" "$f — contas.yaml com cliente preenchido (fora de templates/)"
      fi ;;
  esac

  # --- 3. Conteudo com formato de credencial -------------------------------
  # Binario nao interessa; -I pula.
  while IFS=: read -r linha resto; do
    [ -z "$linha" ] && continue
    # mostra so os 8 primeiros chars do que casou, nunca o segredo inteiro
    amostra=$(echo "$resto" | grep -oE "(sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AIza[A-Za-z0-9_-]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[A-Z0-9]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)" | head -1 | cut -c1-8)
    reportar "CHAVE" "$f:$linha — string com formato de credencial ($amostra…)"
  done < <(grep -nIE "(sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AIza[A-Za-z0-9_-]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[A-Z0-9]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)" "$f" 2>/dev/null | head -3)

  # --- 4. Variavel de ambiente com valor preenchido ------------------------
  # Pega o caso de alguem colar uma chave num .md ou .json de config.
  while IFS=: read -r linha resto; do
    [ -z "$linha" ] && continue
    case "$resto" in
      *SEU_*|*seu-*|*xxx*|*XXX*|*'<'*|*exemplo*|*example*|*placeholder*|*aqui*) continue ;;
    esac
    reportar "CHAVE" "$f:$linha — variavel de credencial com valor preenchido"
  done < <(grep -nIE "^[^#]*\b[A-Z_]*(API_KEY|SECRET|TOKEN|PASSWORD|SENHA|PRIVATE_KEY|ACCESS_KEY)\b[[:space:]]*[=:][[:space:]]*['\"]?[A-Za-z0-9_/+.-]{16,}" "$f" 2>/dev/null | head -3)

done <<< "$STAGED"

echo
if [ "$ACHADOS" -eq 0 ]; then
  echo "Limpo. Nenhuma credencial no que vai ser commitado."
  exit 0
else
  echo "=========================================================="
  echo " $ACHADOS ACHADO(S) — commit abortado"
  echo "=========================================================="
  echo
  echo "O que fazer:"
  echo "  1. Se o arquivo nao deveria ser versionado:"
  echo "       git restore --staged <arquivo>"
  echo "     e mova ele pra inbox/importacao/, que fica fora do git."
  echo "  2. Se e so um exemplo, troque o valor por um placeholder"
  echo "     (SEU_TOKEN_AQUI, xxx) e rode /syncar de novo."
  echo "  3. Se a credencial ja e real e ja foi usada em algum lugar,"
  echo "     REVOGUE ela no painel do servico antes de qualquer coisa."
  exit 1
fi
