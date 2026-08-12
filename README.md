# Mercatus OS

Um segundo cérebro que se monta sozinho pro seu negócio.

Você clona, roda um comando, responde uma entrevista. No fim você tem a estrutura de pastas do seu negócio, o contexto dele escrito, e ferramentas personalizadas pro que você faz toda semana.

---

## Instalar

Abra o Claude Code (ou o Codex), aponte pra pasta onde você quer o sistema, e cole:

```
Instala pra mim o Mercatus OS aqui nesta pasta, com os arquivos soltos
direto aqui e não dentro de outra subpasta. Faz a configuração que o
README manda depois do clone. Depois lê o CLAUDE.md e começa a
configuração comigo.

https://github.com/pedroguedespro/Mercatus-OS
```

Ele instala e **já começa a entrevista**. Funciona igual no Mac e no Windows.

Nunca usou Claude Code nem Codex? Comece por https://mercatus-os-instalar.pages.dev
Depois de instalar, o manual está em https://mercatus-os-instalar.pages.dev/manual/

---

## Como ele instala, e por que importa

O assistente escolhe sozinho entre dois caminhos:

**Com Git (preferido).** Ele clona e configura `upstream` apontando pra cá. Isso é o que permite você receber melhorias depois: quando sair coisa nova, você pergunta `tem novidade?` e ele traz só o que você escolher.

```bash
git clone https://github.com/pedroguedespro/Mercatus-OS.git .
git remote rename origin upstream
git branch --unset-upstream
git config core.hooksPath .githooks
```

**Sem Git (plano B).** Baixa e extrai o conteúdo. Funciona, mas **atualizar depois é manual**. Quando você pedir `tem novidade?`, ele oferece ligar a atualização automática, e aí é rápido.

> Sem Git também não existe `remote`, então não há como o seu trabalho ir parar no repositório errado. É mais simples e mais seguro; só perde a atualização automática.

---

## Comandos

| Comando | O que faz |
|---|---|
| `/setup` | Configura o sistema pro seu negócio. Comece por aqui |
| `/mapear` | Entrevista sobre seus processos e cria ferramentas personalizadas |
| `/iniciar` | Carrega o contexto no começo da sessão |
| `/novo-projeto` | Cria um projeto novo com contexto próprio |
| `/atualizar` | Reconcilia o contexto com o que mudou de verdade |
| `/syncar` | Salva no GitHub, com scanner de credencial antes |

---

## A única regra que quebra tudo

**Abra o Claude Code dentro da pasta.** Ele lê o contexto da pasta onde você abre. Se o Claude parecer não saber nada sobre o seu negócio, é quase sempre isso.

---

## Nada sobe pra nuvem sozinho

Salvar é `/syncar`, explícito. Ele roda um scanner de credencial sobre o que vai ser enviado e **aborta** se achar chave, token ou senha. Um hook de git faz a mesma checagem mesmo se você commitar pela mão.

Isso é decisão, não limitação: commit automático a cada resposta gera dezenas de commits durante uma entrevista, esconde falhas, e pula a conferência do que está subindo.

**`inbox/importacao/`** é onde você joga material cru da empresa — contrato, planilha, export de CRM. Essa pasta fica **fora do git** de propósito, porque é onde credencial e dado de cliente costumam estar. Sobe o destilado, não a fonte.

---

## Rodar os testes

```bash
bash .claude/scripts/testar-scanner.sh
```

Esperado: `19 passou, 0 falhou`.
