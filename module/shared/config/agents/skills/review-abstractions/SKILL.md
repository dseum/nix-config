---
name: review-abstractions
description: Reviews structure in your unpushed work: types, abstraction, naming, and control flow, judged by how locally the code can be reasoned about and how well invariants live in the code itself. Use when asked to review design, judge an abstraction, plan a refactor, or sanity-check recent changes.
---

Default scope is the current session's changes and unpushed commits. Find the range with git: uncommitted diff plus commits ahead of upstream, or the merge-base with the default branch. If the range is unclear, review only what the session touched and say why. A wider review of existing code happens only when asked.

Read the core types and the call sites before judging anything. Most weak designs look fine at the definition and indefensible at the call sites.

## Principles

- Local reasoning is the goal. A function should be understandable by reading it and little else. Value semantics, contained mutation, and explicit data flow serve this; shared state, action at a distance, and cleverness work against it.
- Names carry the design. A precise name can remove a helper and a comment at once. A name that stays vague means the concept is vague; fix the concept first.
- Invariants belong in types, not in checks. Make invalid states unrepresentable so validation happens once, at construction. A check repeated in several places usually means the type is wrong.
- Data before code. Pick the representation first; the right one makes functions short and linear. When branches keep accumulating special cases, suspect the representation and prefer the change that makes the case disappear.
- Inline until a pattern earns a name. Duplication is cheaper than the wrong abstraction. Abstract from concrete cases that already share an invariant, not from predicted futures.
- Abstraction is a trade, not a virtue. It earns its place by hiding more than it costs: an interface you understand without the implementation, call sites that got simpler, a class of change that now touches one place. A layer that fails all three is overhead; fold it back in.
- Style is consistency, not preference. Match the file and the language's idioms. Flat control flow, early exits, boring formatting.

## Report

Default to reporting, not rewriting. For each finding: location, the principle at stake, the failure it causes, and the smallest change that removes it. Rank by severity. If the design is sound, say so. Apply fixes only within scope and when asked.
