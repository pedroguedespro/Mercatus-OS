# Mercatus OS

Um segundo cérebro que se monta sozinho pro seu negócio.

Você clona, roda um comando, responde uma entrevista. No fim você tem a estrutura de pastas do seu negócio, o contexto dele escrito, e ferramentas personalizadas pro que você faz toda semana.

---

## Instalar

> **O caminho suportado é a página de instalação:** https://mercatus-os-instalar.pages.dev
>
> Ela tem o passo a passo com checklist, incluindo o que fazer se algo falhar. As instruções abaixo são um resumo pra quem já conhece o terreno.
>
> ⚠️ Em desenvolvimento ativo, ainda não validado num piloto.

**1. Clone**

```bash
git clone https://github.com/pedroguedespro/Mercatus-OS.git meu-sistema
cd meu-sistema
git remote rename origin upstream
git branch --unset-upstream
```

O `git remote rename` importa: sem ele, o seu primeiro `git push` tentaria escrever no repositório do produto em vez do seu.

**2. Ative a proteção contra commit de credencial**

```bash
git config core.hooksPath .githooks
```

**3. Abra o Claude Code dentro da pasta e rode**

```
/setup
```

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
