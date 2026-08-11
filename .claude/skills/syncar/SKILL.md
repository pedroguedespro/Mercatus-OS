---
name: syncar
description: >
  Salva o trabalho no GitHub, rodando um scanner de credencial antes e abortando
  se achar. Use quando o usuário disser "salva no github", "faz commit", "synca",
  "syncar", "backup", "salva tudo", "manda pro github", ou ao fim de uma sessão
  produtiva. Também conecta o repositório ao GitHub pela primeira vez.
---

# /syncar — salvar no GitHub

**Nada sobe sozinho neste sistema.** Isso é de propósito: um hook de auto-commit dispara ao fim de *cada resposta*, não de cada sessão — numa entrevista de trinta perguntas seriam trinta commits, e falhas ficariam invisíveis. Salvar é aqui, explícito.

## Passo 1 — entender o estado

```bash
git status --short
git remote -v
git branch --show-current
```

Três cenários possíveis, e o **B** é o que mais engana.

---

## Cenário A — sem remote proprio

Nao existe `origin`. Pode existir um `upstream` (quem clonou direto e corrigiu ja tem), e isso **nao muda nada**: sem `origin`, a pessoa trabalha local.

Antes de qualquer commit, confirme que a branch nao ficou rastreando o produto:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
```

Se responder algo com `upstream/`, rode `git branch --unset-upstream` antes de seguir. **Nunca rode `git push` sem `origin`**: use sempre `git push -u origin <branch>` explicito, depois de confirmar que o `origin` e da pessoa. A pessoa está trabalhando 100% local, sem backup.

Pergunte se ela quer conectar agora. Se **não** quiser, respeite: commit local continua funcionando e o trabalho fica versionado na máquina dela.

```bash
git add -A
# rode o scanner (Passo 2) ANTES do commit
git commit -m "sync: <o que foi feito>"
```

> "Salvo no seu computador. Ainda sem cópia na nuvem — se a máquina der problema, isso se perde. Quando quiser conectar ao GitHub, é só falar."

Se **quiser** conectar, vá pro Passo 3.

---

## Cenário B — o remote aponta pro repositório errado ⚠️

`origin` aponta pro repositório **do Mercatus OS**, não pro da pessoa. Acontece quando ela clonou direto em vez de usar o template do GitHub.

**Como reconhecer com segurança.** Não basta olhar o `git remote -v` de olho: a mesma origem aparece em três formatos diferentes, e existe `pushurl` separado do `url`.

```bash
git remote get-url origin
git remote get-url --push origin
```

Compare os dois, normalizados (tanto faz `https://github.com/dono/repo.git`, `git@github.com:dono/repo.git` ou sem `.git` no fim — é o mesmo lugar). Extraia `dono/repo` e decida:

- `dono/repo` é o repositório canônico do Mercatus OS → **é o Cenário B**, corrija
- `dono` é a própria pessoa → é o repositório dela, siga normal
- **qualquer outra coisa** → não adivinhe. Mostre a URL e pergunte: *"esse repositório é seu?"* Um remote de terceiro não pode passar por "próprio" no silêncio.

Se `url` e `pushurl` divergirem, trate como suspeito e pergunte — é exatamente a configuração que faz o `push` ir pra um lugar diferente do `fetch`.

**Não deixe passar.** O primeiro `push` tentaria escrever no repositório do produto — vai falhar por falta de permissão, ou pior, se ela tiver acesso, vai poluir o produto com o trabalho dela.

Corrija na hora:

```bash
git remote rename origin upstream
git branch --unset-upstream
```

> **A segunda linha nao e opcional.** O `rename` tira o `origin`, mas o rastreamento da branch migra junto e vira `upstream/main`. Um `git push` depois disso resolve o destino em silencio e manda o trabalho da pessoa pro repositorio do produto. Verificado em teste: o `git push --dry-run` responde "Everything up-to-date" em vez de reclamar que nao ha destino.

> "Ajustei uma coisa: o repositório estava apontando pro Mercatus OS original, não pro seu. Renomeei pra `upstream` — assim você continua podendo puxar atualizações do sistema, mas o seu trabalho não vai tentar ir pra lá."

Agora está no Cenário A. Pergunte se ela quer criar o repositório dela.

---

## Cenário C — remote próprio configurado

Segue normal. Vá pro Passo 2.

---

## Passo 2 — o scanner (nunca pule)

```bash
git add -A
bash .claude/scripts/scanner-segredo.sh
```

**Se sair com código 1, PARE. Não commite.** Mostre o que ele achou e conduza a correção — o próprio scanner imprime as três saídas possíveis.

O scanner olha só o que está *staged*, não a pasta inteira. `inbox/importacao/` é ignorado pelo git, então material cru nem chega ali — o que ele pega é o caso de a pessoa ter **movido** um arquivo importado pra uma área versionada sem notar que tinha credencial dentro.

Se ele achar uma chave que **já é real e já foi usada**, a primeira coisa não é apagar o arquivo: é **revogar a chave** no painel do serviço. Uma chave que passou pelo disco de alguém já deve ser considerada comprometida.

Passando limpo:

```bash
git commit -m "sync: <descrição curta>"
git push
```

Descrição vem do que foi feito na sessão: `sync: proposta do cliente X`, `sync: contexto da empresa Y`. Sem ideia? `sync: atualizações do dia`.

---

## Passo 3 — conectar ao GitHub pela primeira vez

Só entre aqui se a pessoa disse que quer. Uma etapa por vez, esperando resposta.

**3.1 — Ela tem conta no GitHub?** Se não: github.com/signup. É grátis. Explique em uma linha o que é: um lugar na internet que guarda o histórico do seu trabalho, com cada versão salva. Se ela não quiser criar conta, volte pro Cenário A sem insistir.

**3.2 — O git está instalado e autenticado?**

```bash
git --version
git config --global user.name
git config --global user.email
```

Faltando nome ou email:
```bash
git config --global user.name "Nome da Pessoa"
git config --global user.email "email@dela.com"
```

**3.3 — Autenticação.** No Windows, o Git for Windows já vem com o **Git Credential Manager**: no primeiro `push` ele abre o navegador, a pessoa faz login no GitHub e pronto. Sem token, sem SSH, sem copiar código.

> **Não sugira criar Personal Access Token como primeiro caminho.** É o mais difícil e o que mais trava quem está começando. PAT e SSH são fallback, só se o GCM não estiver disponível.

Confirme se o GCM está lá:
```bash
git config --global credential.helper
```
Se retornar `manager` ou `manager-core`, está resolvido — o navegador cuida do resto.

No Mac, o padrão é `osxkeychain` + login no navegador. No Linux, aí sim pode precisar de PAT ou SSH — pergunte antes de assumir.

**3.4 — Criar o repositório.**

> "Vá em github.com/new. Nome pode ser `meu-sistema`. Marque **Private** — o que vai aqui dentro é o contexto do seu negócio. **Não** marque nenhuma das caixas de inicializar com README. Depois me manda o link."

**3.5 — Conectar, e então voltar pro Passo 2.**

```bash
git remote add origin <link>
git branch -M main
```

> **Não faça `push` daqui.** Configurar o remote não commita nada — se a pessoa tem trabalho não commitado (e ela quase sempre tem, é por isso que chamou o `/syncar`), um `push` agora enviaria um repositório vazio e deixaria tudo pra trás.

**Volte ao Passo 2:** `git add -A`, scanner, commit. Só então:

```bash
git push -u origin main
```

> "Pronto. Seu trabalho está em <link>, num repositório privado que só você vê.
> Daqui pra frente, sempre que quiser salvar é só falar `/syncar`."

---

## Se o push falhar

Nunca mostre só o erro. Traduza e diga o que fazer.

| O que apareceu | O que é | O que fazer |
|---|---|---|
| `Authentication failed` / `could not read Username` | Autenticação | Ver 3.3. No Windows, o GCM deveria abrir o navegador |
| `Permission denied` / `403` | Sem acesso àquele repositório | Provavelmente é o Cenário B — confira `git remote -v` |
| `rejected` / `non-fast-forward` | Alguém (ou outro computador seu) enviou algo antes | `git pull --rebase` e tenta de novo |
| `Could not resolve host` | Sem internet | Commit local já foi feito, nada se perdeu. Push depois |
| `repository not found` | Link errado ou repositório apagado | Conferir o link em `git remote -v` |

---

## Se tem sócio no repositório

Cada pessoa trabalha na **própria branch** — a bancada dela. Todo mundo enxerga a de todo mundo, e a `main` é a mesa comum, onde só entra o que já foi revisado.

```bash
git checkout -b <nome-da-pessoa>
git push -u origin <nome-da-pessoa>
```

Pra dar acesso: no GitHub, Settings → Collaborators → Add people.

---

## Dado de cliente — o que o scanner NÃO pega

O scanner acha **credencial**. Ele não sabe distinguir sigilo comercial: contrato, lista de clientes, tabela de preços, CPF/CNPJ, planilha com nome e telefone de pessoa real. Nada disso tem formato reconhecível.

E aqui o trabalho **é** versionado — proposta, briefing e contexto de cliente sobem de propósito, senão o backup não vale nada. Então a regra é operacional, não automática:

- **Material bruto fica em `inbox/importacao/`**, que está fora do git. Contrato assinado, export de CRM, planilha de cliente: é ali que vivem.
- **Sobe o destilado, não a fonte.** "Cliente X é do setor Y, ticket médio Z" pode subir. O PDF do contrato dele, não.
- **Antes de commitar algo que identifica pessoa ou empresa de terceiro**, pare e confirme: *"isso tem nome de cliente / CPF / valor de contrato dentro. Pode subir pro repositório?"* Se houver sócio no repositório, lembre que ele vai ler.

Isso vale mais quando o repositório é compartilhado: o que é normal você guardar sozinho pode não ser o que o teu cliente esperava que o teu sócio visse.

## Regras

- **Scanner antes de todo commit.** Sem exceção, mesmo que a pessoa tenha pressa.
- **Nunca sugira `git commit --no-verify`** pra contornar o hook. Ele existe porque credencial commitada não se apaga: fica no histórico mesmo depois do arquivo ser deletado.
- **Skill instalada por `git clone` precisa perder o `.git/`**, senão vira ponteiro vazio e some do backup. O comando certo é `git clone --depth 1 <url> <destino> && rm -rf <destino>/.git`.
- **Nunca `git push --force`** sem a pessoa entender que isso apaga histórico do servidor.
- Tom direto. Não explica git em detalhe a menos que perguntem.
- Erro sempre vem com o próximo passo, nunca sozinho.
- Se algo der errado no meio, diga o que **já** foi salvo e o que não foi. "Commitei mas não consegui enviar" é informação útil; "deu erro" não é.
