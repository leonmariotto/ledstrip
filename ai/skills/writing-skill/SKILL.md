---
name: skill-creator
description: Create, rewrite, or tighten SKILL.md files for other agents. Use when the user wants a new skill, a revision of an existing skill, or a reusable skill template.
---

# Skill Creator

Create `SKILL.md` files that agents can follow reliably.

## Objective

The agent context is precious, we must not bloat it. Skills are a way to provide information to the agent without bloating its context.
Concise is key.

## Required structure

SKILL.md is a layered package of imformation. It contains roughly 3 layers :
- metadata: yaml frontmarker that is always loaded in the context. It must be concise, but must provide enough information for the model to know when to load the SKILL.md
It should not be > 30 words. The `description` must say when the skill should be used and what it does. Keep it concrete and activation-friendly.
- body: the entire SKILL.md file. Should not be > 100 lines.
- extra: extra detailed informations, scripts, templates, loaded when needed.
This layered structure is the key to provide informations to agents whil preserving their context.

## Default procedure

1. Identify the skill's job in one sentence.
2. Write a precise `description`.
3. Define narrow trigger conditions.
4. Define the output before style guidance.
5. Add default steps the agent should follow.
6. Add constraints that prevent common mistakes.
7. Add at least one short example.
8. Remove redundancy and vague wording.

## Rules

- You must balance between general instruction (text based) or direct script (less general).
- Depending of the SKILL subject, you may want to stay general so that agents using the SKILL can have a lot of freedom,
or provide specific script and direct values so that agents is more efficient.
- Keep the file compact. (< 100 lines)

## Assumptions

Agents are already smart. Do not provide informations that Agents probably already know.

## Template

Use `template.md` as a template.
