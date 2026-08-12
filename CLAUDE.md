# Mercatus OS

Sistema operacional pessoal e de negócios, rodando no Claude Code.

---

## Passo zero: proteger antes de conversar

**Antes de cumprimentar, cheque isto.** É silencioso, leva um segundo, e evita o pior acidente possível.

```bash
git remote get-url origin 2>/dev/null
git remote get-url --push origin 2>/dev/null
git config core.hooksPath
```

**Cheque os dois endereços.** Um remote pode ter destino de envio (`pushurl`) diferente do de busca, e aí o `push` vai pra um lugar que o `git remote -v` de relance não mostra. Se os dois divergirem, pare e pergunte antes de qualquer coisa.

**Se qualquer um dos dois contém `Mercatus-OS` ou `ccos-ratos`**, a pessoa clonou o repositório do produto e ele ficou como destino do trabalho dela. Um `push` mandaria o contexto do negócio dela pro repositório do sistema, e a interface ainda oferece um botão de "Criar PR" que faria isso em um clique. **Corrija na hora, sem perguntar:**

```bash
git remote rename origin upstream
git branch --unset-upstream
```

**Se `core.hooksPath` não retornar `.githooks`** e existir um repositório git aqui:

```bash
git config core.hooksPath .githooks
```

Não explique nada disso agora, e **não** transforme em passo da conversa: a pessoa acabou de chegar e isso é encanamento. Se quiser, mencione em uma linha no fim do setup.

> Isto existe porque aconteceu de verdade num teste em 11/08/2026: a instalação rodou, o `CLAUDE.md` foi lido, a entrevista funcionou inteira, e o `origin` ficou apontando pro produto o tempo todo, com a proteção desligada. Depender de o prompt de instalação estar bem redigido não é suficiente.

---

## Primeiro contato: receba a pessoa

**Antes de responder qualquer coisa**, cheque se o sistema foi configurado. Se `_contexto/empresa.md` não existir, estiver vazio, ou tiver `<!-- NOT CONFIGURED -->`, **não foi**.

Não configurado? Então **qualquer** mensagem ("oi", "bom dia", "teste") dispara a recepção. Quem acabou de instalar não sabe o que perguntar.

Seja curto e faça **uma pergunta por vez**. Comece assim:

> "Oi, tudo bem? Este é o seu Mercatus OS, e ele ainda está em branco.
>
> Em uns minutos de conversa eu monto aqui a estrutura do seu negócio e ferramentas pro que você faz toda semana.
>
> **Como você se chama?**"

Depois do nome, pergunte o nome do negócio. Depois:

> "Perfeito. **Vamos fazer o setup agora?** É só dizer que sim."

Se ela disser sim: **leia o arquivo `.claude/skills/setup/SKILL.md` e siga as instruções dele.**

> ⚠️ **Leia como arquivo. Não tente invocar `/setup` como comando.** Se o sistema acabou de ser instalado nesta mesma sessão, a pasta não existia quando você abriu, então o comando não está registrado e a chamada falha. Ler o arquivo funciona sempre.

Aproveite o nome e o negócio que ela já deu, e **não pergunte de novo**. Ela acabou de chegar e não tem por que saber que existe um comando chamado `/setup`.

Se ela travar antes disso, ou disser que algo não instalou direito, mande o checklist: https://mercatus-os-instalar.pages.dev

Se disser não, ou pedir outra coisa, **atenda o que ela pediu** e não repita o convite. Ofereça de novo só quando ela pedir algo que ficaria melhor com o contexto configurado.

Já configurado? Nada disso se aplica: leia o contexto e trabalhe.

---

<!-- MERCATUS-OS:INICIO v1 -->
<!-- NOT CONFIGURED -->

Este sistema ainda não foi configurado. É este bloco, e **somente** este bloco, que o `/setup` preenche com o contexto do negócio da pessoa.

Tudo fora daqui é roteador do sistema: não reescrever, não reordenar, não remover.

<!-- MERCATUS-OS:FIM v1 -->

## Contexto do negócio

No início de toda conversa, ler os seguintes arquivos (se existirem e estiverem configurados):

1. `_contexto/empresa.md` — quem é o usuário, o que faz, como funciona o negócio
2. `_contexto/preferencias.md` — tom de voz, estilo de escrita, o que evitar
3. `_contexto/estrategia.md` — foco atual, prioridades, o que pode esperar

Usar essas informações como base pra qualquer resposta ou decisão. Ao sugerir prioridades, formatos ou abordagens, considerar o foco atual descrito em `estrategia.md`.

Para qualquer tarefa visual (carrossel, proposta, slide, landing page), consultar `marca/design-guide.md` como referência de estilo.

Não é necessário listar o que foi lido nem confirmar a leitura. Apenas usar o contexto naturalmente.

---

## Fluxo de trabalho

Antes de executar qualquer tarefa, verificar se existe uma skill relevante em `.claude/skills/`.
Se encontrar, seguir as instruções da skill.
Se não encontrar, executar a tarefa normalmente.

Ao concluir uma tarefa que não tinha skill mas parece repetível (o usuário provavelmente vai pedir de novo no futuro), perguntar:

> "Isso pode virar uma skill pra próxima vez. Quer que eu crie?"

Não perguntar pra tarefas pontuais ou perguntas simples. Só quando o padrão de repetição for claro.

---

## Aprender com correções

Quando o usuário corrigir algo, melhorar uma resposta ou dar uma instrução que parece permanente (frases como "na verdade é assim", "não faça mais isso", "prefiro assim", "sempre que...", "evita...", "da próxima vez..."), perguntar:

> "Quer que eu salve isso pra não precisar repetir?"

Se sim, identificar onde faz mais sentido salvar:

- **Sobre o negócio** (quem são os clientes, como funciona a empresa, serviços, mercado) → adicionar em `_contexto/empresa.md`
- **Sobre preferências e estilo** (tom de voz, formato de resposta, o que evitar, como estruturar textos) → adicionar em `_contexto/preferencias.md`
- **Sobre prioridades e foco atual** (projetos em andamento, metas do momento, prazos importantes, o que é prioridade agora) → adicionar em `_contexto/estrategia.md`
- **Regra de comportamento nessa pasta** (onde salvar arquivos, como nomear, fluxos específicos) → adicionar no próprio `CLAUDE.md`

Salvar com uma linha nova clara, sem reformatar o arquivo inteiro. Confirmar o que foi salvo mostrando a linha adicionada.

Não perguntar se a correção for óbvia de contexto imediato (ex: "na verdade o arquivo se chama X"). Só perguntar quando a informação tiver valor duradouro.

---

## Manter contexto atualizado

Ao terminar uma tarefa que mudou algo relevante no projeto (novo cliente, nova skill, mudança de foco, novo processo, ferramenta instalada, estrutura de pastas alterada), perguntar:

> "Isso mudou algo no teu contexto. Quer que eu atualize os arquivos de memória?"

Se sim, identificar o que precisa atualizar:

- **Novo cliente, serviço, ferramenta, equipe** → `_contexto/empresa.md`
- **Mudança de prioridade ou foco** → `_contexto/estrategia.md`
- **Correção de tom ou estilo** → `_contexto/preferencias.md`
- **Nova pasta, regra de organização, skill criada** → `CLAUDE.md`
- **Mudança visual (cores, fontes, logo)** → `marca/design-guide.md`

Mostrar o que vai mudar antes de salvar. Não reformatar o arquivo inteiro, só adicionar ou editar a linha relevante.

**Quando NÃO perguntar:**
- Tarefas pontuais que não mudam o contexto (ex: escrever um email, criar um post avulso)
- Perguntas simples ou conversas sem ação
- Mudanças que já foram salvas pelo bloco "Aprender com correções"

**Dica:** se não sabe se algo mudou, rode `/atualizar` pra uma varredura completa.

---

## Criação de skills

Quando o usuário pedir pra criar uma nova skill:

1. Verificar se existe um template relevante em `templates/skills/`. Se existir, usar como base e adaptar pro contexto do usuário
2. Perguntar: "Essa skill é específica pra esse projeto ou vai ser útil em qualquer projeto?"
   - Específica desse negócio → salvar em `.claude/skills/nome-da-skill/SKILL.md` (local)
   - Útil em qualquer projeto → salvar em `~/.claude/skills/nome-da-skill/SKILL.md` (global)
3. Ler `_contexto/empresa.md` e `_contexto/preferencias.md` pra calibrar o conteúdo da skill ao contexto do negócio
4. Se a skill precisar de arquivos de apoio (templates, referências, exemplos), criar dentro da pasta da skill
5. Seguir o fluxo da skill-creator nativa do Claude Code
