#!/usr/bin/env bash
# Teste reproduzivel do scanner de segredo.
#
# Metade dos casos DEVE ser pega (verdadeiro positivo) e metade DEVE passar
# (falso positivo). As duas metades importam igual: um scanner que grita
# demais ensina a pessoa a ignorar o aviso, e ai ele nao protege mais nada.
#
# Uso: bash .claude/scripts/testar-scanner.sh

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1
T="_teste-scanner-tmp"
PASSOU=0; FALHOU=0

limpar() { git rm -r --cached "$T" -q 2>/dev/null; rm -rf "$T"; }
trap limpar EXIT
rm -rf "$T"; mkdir -p "$T"

# caso <nome> <deve_pegar:sim|nao> <arquivo> <conteudo>
caso() {
  local nome="$1" espera="$2" arq="$3" conteudo="$4"
  rm -rf "$T"; mkdir -p "$(dirname "$T/$arq")"
  printf '%s\n' "$conteudo" > "$T/$arq"
  git add -f "$T" >/dev/null 2>&1
  if bash .claude/scripts/scanner-segredo.sh >/dev/null 2>&1; then achou="nao"; else achou="sim"; fi
  git rm -r --cached "$T" -q >/dev/null 2>&1
  if [ "$achou" = "$espera" ]; then
    printf "  ok    %-46s (pegou=%s)\n" "$nome" "$achou"; PASSOU=$((PASSOU+1))
  else
    printf "  FALHA %-46s (esperado=%s, deu=%s)\n" "$nome" "$espera" "$achou"; FALHOU=$((FALHOU+1))
  fi
}

echo "=== DEVE PEGAR ==="
caso "JSON com aspas"          sim "a.json" '{"access_token":"ya29.a0ARrdaM9xKfPqL2mNvBw"}'
caso "YAML sem aspas"          sim "a.yaml" 'access_token: ya29.a0ARrdaM9xKfPqL2mNvBw'
caso "YAML com aspas"          sim "b.yaml" 'client_secret: "GOCSPX-AbCdEf1234567890xyz"'
caso "TOML sem aspas"          sim "a.toml" 'api_key = AbCdEf1234567890GhIjKlMn'
caso "nome de arquivo token"   sim "token.json" '{"x":1}'
caso "nome oauth"              sim "oauth-google.json" '{"x":1}'
# As fixtures abaixo sao montadas em TEMPO DE EXECUCAO, nunca escritas
# literais neste arquivo. Motivo: o hook de pre-commit escaneia este proprio
# arquivo e bloquearia o commit dele. A alternativa — abrir excecao pro
# caminho deste teste — seria um buraco que qualquer um explora nomeando
# o arquivo igual. Aqui o scanner continua valendo pra tudo, sem excecao.
_SK="sk"; _GH="ghp"; _BEG="-----BE""GIN"; _KEY="KEY"

caso "chave OpenAI no md"      sim "n.md"   "minha chave: ${_SK}-proj-AbCdEfGh1234567890IjKlMnOp"
caso "PAT do GitHub"           sim "n.md"   "${_GH}_AbCdEfGhIjKlMnOpQrStUvWxYz01234567"
caso "env var preenchida"      sim "c.txt"  "ELEVENLABS_API_${_KEY}=a1b2c3d4e5f6g7h8i9j0k1l2"
caso "chave privada PEM"       sim "k.txt"  "${_BEG} RSA PRIVATE ${_KEY}-----"
caso ".env real"               sim ".env"   'X=1'

echo
echo "=== DEVE PASSAR (falso positivo) ==="
caso "placeholder SEU_"        nao "d.json" '{"api_key":"SEU_TOKEN_AQUI"}'
caso "placeholder YOUR_"       nao "e.txt"  'OPENAI_API_KEY=YOUR_API_KEY_HERE'
caso "placeholder CHANGEME"    nao "f.yaml" 'client_secret: CHANGEME_antes_de_usar'
caso "placeholder angular"     nao "g.toml" 'token = <cole seu token aqui>'
caso "exemplo explicito"       nao "h.json" '{"secret":"example-value-not-real"}'
caso ".env.example"            nao ".env.example" 'OPENAI_API_KEY=SEU_TOKEN_AQUI'
caso "texto comum longo"       nao "i.md"   'O relatorio mostra que a taxa de conversao subiu 12% no trimestre.'
caso "campo curto"             nao "j.json" '{"token":"abc"}'

echo
echo "=================================================="
printf " %d passou, %d falhou\n" "$PASSOU" "$FALHOU"
echo "=================================================="
[ "$FALHOU" -eq 0 ] || exit 1
