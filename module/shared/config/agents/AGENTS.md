## General

- In any language you use, use correct, modern, elegant, idiomatic syntax. Code aesthetics are critical for maintainability and scalability.
- Only add code comments when realistically helpful. Noisy comments are always worse than no comments.
- Do not overly abstract code into functions used only once or for a trivial purpose. Non-local control flow is always more difficult to understand than local control flow, so prefer keeping it local.
- Only add meaningful tests. Determining whether something needs a test and writing that test require deep thinking equivalent to writing a program itself.
- Ask questions if you are uncertain about anything.

## Environment

- Nix and comma (`,`) are installed for obtaining tools and dependencies and creating environments as needed.

## Git

### Issues

Never create.

### Commits

Create commits and push only when the user explicitly asks.

#### Format

```text
<type>[!]: <description>
```

- Use `feat` for features and `fix` for bug fixes. Other lowercase types, such as `docs`, `refactor`, `test`, `ci`, and `chore`, are allowed
- Keep the description concise
- Mark breaking changes with `!` before `:`
- Do not use a body or a footer unless the user explicitly asks

### Pull Requests

Create only when the user explicitly asks. Never add a description; once the PR is created, provide the link to the user so the user can add a description.
