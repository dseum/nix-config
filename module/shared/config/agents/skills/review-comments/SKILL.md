---
name: review-comments
description: Reviews comments written in the current session or your unpushed commits, keeping the ones that say what the code cannot and folding the rest into names and structure. Use when asked to review or write comments; a whole-repo pass happens only when explicitly requested.
---

Default scope is comments added in the current session or in your unpushed commits. Find the range with git: uncommitted diff plus commits ahead of upstream, or the merge-base with the default branch. If the range is unclear, touch only what the session wrote. Everyone else's comments and committed work stay untouched unless explicitly asked for a global review.

## Judgment

- Comments say what the code cannot: why a choice was made, a constraint from outside the code, a warning against a tempting change, the name of the algorithm. Anything the code can say itself belongs in a name, a type, or a restructure; prefer that to keeping the comment.
- Fewer comments, better comments. Aim for ones a colleague would say out loud while pointing at the screen. Deletion first, rewrite second, addition last, and the empty set is a fine outcome.
- Pure ASCII: no em or en dashes, smart quotes, unicode arrows, box drawing, or emoji. Do not transliterate them into `-` or `->`; rephrase the sentence so the words carry what the mark was implying.
- Form follows language and place. API documentation uses the language's doc convention (rustdoc, godoc, docstrings, JSDoc) so it renders; inline comments answer a local why. Match the file's existing style over any rule here.
- Flags like TODO, FIXME, and HACK mark known debt and are worth keeping. A flag earns its place when a reader knows what would let it be removed, in the repo's convention; one that just admits imperfection is noise.

Report what you removed, rewrote, or added and why, or apply the edits when asked to fix. Touch nothing but comments inside the scope.
