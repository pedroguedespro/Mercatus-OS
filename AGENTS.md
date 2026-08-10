# AGENTS.md

Ponteiro cross-IA. **Não duplica contexto** — duas cópias divergem e ninguém sabe qual vale.

## Fonte de verdade

`CLAUDE.md` na raiz deste repositório. Leia primeiro, sempre.

As capacidades do sistema vivem em `.claude/skills/`. Cada uma tem um `SKILL.md` com o que faz e quando disparar.

## Regra do adaptador

O adaptador é fino. Quando o motor suporta skill, aponte pros arquivos que já existem em `.claude/skills/` — não reescreva a lógica em outro formato.

Quando o motor só aceita arquivo de instrução, mantenha o texto alinhado com este arquivo, que aponta pro `CLAUDE.md`.

**Nunca criar `GEMINI.md`, `.codex/` ou equivalente dentro do repositório** com cópia do contexto. Se um motor precisa de config própria, ela vai no config global daquele motor, apontando pra cá.

## A ponte pro Codex

O Codex procura skills em `.agents/skills/`, não em `.claude/skills/`. Em vez de manter duas pastas (que divergem na primeira edição), existe uma **ponte**: um link de `.agents/skills` pra `.claude/skills`.

```bash
bash scripts/sync-ponte.sh          # Mac e Linux
```
```powershell
powershell -File scripts\sync-ponte.ps1   # Windows
```

Roda quantas vezes quiser, é idempotente.

**`.agents/` é gerado, não versionado** — está no `.gitignore`. Isso importa: se a ponte cair no modo cópia (quando o sistema não permite link) e a cópia fosse versionada, viraria uma segunda fonte de verdade divergindo em silêncio. A fonte é sempre `.claude/skills/`.

## Estado dos motores

| Motor | Como lê |
|---|---|
| Claude Code | `CLAUDE.md` + `.claude/skills/` nativamente |
| Codex CLI | este `AGENTS.md` + `.agents/skills/` via ponte |
| Gemini CLI | `~/.gemini/settings.json` com `context.fileName: ["AGENTS.md"]` |
| Antigravity | este `AGENTS.md` como regra sempre-ligada |
