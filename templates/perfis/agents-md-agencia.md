# AGENTS.md

<!-- GERADO pelo /setup a partir de templates/perfis/agents-md-agencia.md.
     Regerado pelo /atualizar. Editar a mao aqui se perde na proxima
     atualizacao: mexa em _contexto/ e rode /atualizar. -->

> Perfil: **agencia**

Este arquivo e **autossuficiente de proposito**. Codex, Gemini CLI e outros motores leem ele e ja tem tudo: nao precisam ir atras de outro arquivo, e a pessoa nao precisa saber se foram.

---

## Quem e e o que faz

[o /setup preenche a partir de _contexto/empresa.md]

## Como escrever e o que evitar

[o /setup preenche a partir de _contexto/preferencias.md]

## Foco atual

[o /setup preenche a partir de _contexto/estrategia.md]

## O que esta quente esta semana

[o /setup preenche a partir de _contexto/agora.md]

---

## Ferramentas disponiveis

As capacidades vivem em `.claude/skills/`, cada uma com um `SKILL.md` que diz o que faz e quando disparar. Leia a pasta pra saber o que existe.

**Codex:** rode `bash scripts/sync-ponte.sh` (Mac/Linux) ou `powershell -File scripts\sync-ponte.ps1` (Windows) uma vez, e as skills aparecem em `.agents/skills/`.

## Contrato de atualizacao

A fonte de verdade continua sendo `_contexto/` e `CLAUDE.md`. Este arquivo e uma **projecao** deles, regerada pelo `/atualizar`.

Se voce for um motor de IA e o usuario corrigir algo permanente, escreva em `_contexto/` e avise que ele rode `/atualizar` pra propagar. Nao edite este arquivo direto: a proxima geracao apaga.
