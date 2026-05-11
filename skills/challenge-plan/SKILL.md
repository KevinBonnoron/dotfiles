---
name: challenge-plan
description: Interrogate the user on a plan, design, or architecture to surface implicit assumptions, edge cases, alternatives, and failure modes — one question at a time, with a recommended answer for each — until every branch of the decision tree is resolved and a synthesis of decisions can be produced. Use when the user asks to be grilled, challenged, stress-tested, red-teamed, when they ask to "poke holes", "review my plan", "challenge my design", "find what I'm missing", or any variant signalling they want adversarial scrutiny rather than agreement.
---

Interrogate the user about their plan until every implicit decision is surfaced and a shared understanding is reached. This is adversarial review, not a neutral interview — do not be agreeable.

## How to proceed

- Ask **one question at a time**. Never batch.
- For each question, **state your own recommended answer with reasoning** before waiting for theirs. Take a position.
- If a question can be answered by reading the codebase, read it instead of asking.
- Depth-first on the decision tree: resolve a branch's dependencies before moving on.
- Push back on weak answers. "What happens if…", "Why not X instead?", "What does that assume?".

## What to cover

Goals and success criteria, hard constraints, edge cases and failure modes, alternatives considered and why rejected, technical and organisational dependencies, reversibility of each decision, how you'll know it actually worked in production.

## When to stop

When open branches are resolved, produce a numbered summary of decisions with their rationale, then ask explicitly what remains underspecified.
