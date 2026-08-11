---
name: atualizar-sistema
description: >
  Verifica se saiu versão nova do Mercatus OS e traz as novidades que a pessoa
  escolher, sem tocar no trabalho dela. Use quando ela disser "tem atualização?",
  "atualiza o sistema", "saiu coisa nova?", "quero as novidades", "/atualizar-sistema".
  NÃO confundir com /atualizar, que atualiza o contexto do negócio dela.
---

# /atualizar-sistema

Traz melhorias do Mercatus OS pro sistema dela. **Nunca toca no trabalho dela**: contexto, empresas, conteúdo e skills que ela criou ficam intocados.

## A diferença que confunde

| Comando | O que atualiza |
|---|---|
| `/atualizar` | O contexto **do negócio dela** (mudou cliente, foco, ferramenta) |
| `/atualizar-sistema` | O **Mercatus OS em si** (ferramenta nova, correção, melhoria) |

Se ela pedir "atualiza" sem qualificar, pergunte qual dos dois.

## Passo 1 — descobrir como ela instalou

```bash
git rev-parse --git-dir 2>/dev/null && git remote -v
```

**Tem git e um remote `upstream`:** siga pro Passo 2. É o caminho bom.

**Tem git mas sem `upstream`:** configure antes.
```bash
git remote add upstream https://github.com/pedroguedespro/Mercatus-OS.git
```

**Não tem git:** ela instalou por download. Explique, sem culpar ninguém:

> "Do jeito que está instalado aqui, eu não consigo ver o que mudou nem trazer só as novidades. Consigo baixar a versão nova e comparar na mão, mas é mais lento e mais fácil de dar errado.
>
> **Quer que eu ligue a atualização automática?** É rápido, e depois disso você só me pede 'tem novidade?' e eu resolvo em segundos."

Se ela quiser, siga **exatamente esta ordem** (é a mesma do Cenário ZERO do `/syncar`):

```bash
git init -b main
git remote add upstream https://github.com/pedroguedespro/Mercatus-OS.git
git fetch upstream
git reset --soft upstream/main
git add -A && git commit -m "meu trabalho ate aqui"
```

> ⚠️ **Sem o `reset --soft`, isto não funciona.** Um `git init` comum cria um histórico que não tem nada em comum com o sistema, e o `git merge` depois falha com *"refusing to merge unrelated histories"*. Verificado em teste. O `reset --soft` não altera nenhum arquivo dela: só declara o sistema como ponto de partida.

Se ela não quiser ligar, baixe a versão nova numa pasta temporária e compare arquivo a arquivo, mostrando as diferenças antes de aplicar qualquer coisa.

## Passo 2 — ver o que mudou

```bash
git fetch upstream --quiet
git log --oneline HEAD..upstream/main
```

Nada? Diga e encerre:

> "Você já está na versão mais recente."

## Passo 3 — traduzir, não listar

**Não mostre mensagem de commit.** Elas são escritas pra quem desenvolve, não pra quem usa. Leia o que mudou e conte em português o que muda **na vida dela**:

> "Saíram três coisas desde que você instalou:
>
> **1. Uma ferramenta nova pra analisar anúncios.** Se você anuncia no Instagram, ela lê a conta e diz o que está queimando dinheiro.
>
> **2. O `/mapear` ficou mais rápido.** Antes ele fazia perguntas demais antes de entender o processo.
>
> **3. Uma correção:** quem tinha mais de um negócio às vezes via contexto de um vazando no outro.
>
> **Quer trazer?**"

Agrupe por benefício, e **diga também o que não interessa a ela**: se ela não anuncia, avise que a primeira não faz diferença no caso dela. Vender melhoria que não serve gasta a confiança dela.

> ⚠️ **Não ofereça escolher quais.** A atualização vem em bloco: `git merge` traz tudo ou nada. Prometer seleção e depois entregar o pacote inteiro é pior do que ser claro desde o começo. Diga o que vem, e ela decide trazer ou adiar.

## Passo 4 — aplicar sem quebrar

Antes de qualquer coisa, garanta que o trabalho dela está a salvo:

```bash
git status --short
```

Se houver mudança não salva, **pare** e ofereça salvar primeiro (`/syncar` ou commit local). Nunca aplique atualização por cima de trabalho não salvo.

Então traga:

```bash
git merge upstream/main
```

**Se der conflito**, não mostre marcador de conflito pra ela. Conflito quase sempre significa que ela editou um arquivo que a gente também mudou.

Regra por tipo de arquivo:
- **Contexto e trabalho dela** (`_contexto/`, `empresas/`, `conteudo/`, skills que ela criou): mantenha **a versão dela**, sempre.
- **Arquivo do sistema** (skill do núcleo, script, template): mantenha **a versão nova**, porque é justamente a melhoria que ela pediu.
- **`CLAUDE.md`:** só o bloco entre `MERCATUS-OS:INICIO` e `MERCATUS-OS:FIM` é dela. O resto é roteador e deve receber a versão nova. Mantendo o arquivo inteiro dela, ela perderia a melhoria em silêncio.

Depois avise:

> "Você tinha personalizado o arquivo X. Mantive a sua versão e deixei a nossa de lado, pra você não perder o que ajustou. Se quiser ver a diferença, é só pedir."

## Passo 5 — confirmar em uma linha

> "Pronto, atualizado. A ferramenta nova de anúncios já está disponível: é só pedir."

Se algo exigir ação dela (chave de API, conta em serviço), diga agora e em uma frase, não em tutorial.

## Regras

- **Trabalho dela é intocável.** `_contexto/`, `empresas/`, `conteudo/` e skills criadas por ela nunca são sobrescritas por atualização.
- **Nunca atualize sem perguntar**, mesmo que a melhoria seja óbvia.
- **Nunca mostre mensagem de commit, hash ou diff** a menos que ela peça.
- Se ela recusar, registre e **não ofereça de novo na mesma sessão**.
