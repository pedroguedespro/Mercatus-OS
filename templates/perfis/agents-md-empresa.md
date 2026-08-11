# AGENTS.md

> Template de perfil: **empresa**. O `/setup` usa este arquivo pra gerar o `AGENTS.md` da raiz.

Ponteiro cross-IA. **Não duplica contexto.**

## Fonte de verdade

`CLAUDE.md` na raiz. Leia primeiro, sempre. As capacidades vivem em `.claude/skills/`, cada uma com um `SKILL.md`.

O contexto do negócio está em `_contexto/`:

| Arquivo | O que tem |
|---|---|
| `empresa.md` | quem é, o que faz, como funciona o negócio |
| `preferencias.md` | tom de voz, o que evitar |
| `estrategia.md` | foco de fundo, prioridades |
| `agora.md` | o que está quente esta semana |

## Regra do adaptador

O adaptador é fino. Se o motor suporta skill, aponte pros arquivos que já existem em `.claude/skills/` em vez de reescrever a lógica.

**Nunca criar `GEMINI.md`, `.codex/` ou equivalente dentro do repositório** com cópia do contexto. Config de motor vai no config global daquele motor, apontando pra cá.

## A ponte pro Codex

O Codex procura skills em `.agents/skills/`. Em vez de manter duas pastas que divergem na primeira edição, existe um link:

```bash
bash scripts/sync-ponte.sh              # Mac e Linux
powershell -File scripts\sync-ponte.ps1  # Windows
```

`.agents/` é gerado, não versionado.
