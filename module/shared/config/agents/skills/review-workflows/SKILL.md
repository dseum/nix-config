---
name: review-workflows
description: Applies secure, maintainable conventions to GitHub Actions workflows and local actions. Use when creating, modifying, reviewing, auditing, or sanity-checking Actions configuration, especially dependency pins, permissions, failure behavior, and naming.
---

## Workflow

1. Establish the task and scope. For a review, include uncommitted workflow changes and commits ahead of upstream; if that range is unclear, inspect only files changed in the current session. For implementation, limit edits to the requested behavior and its dependencies.
2. Read each execution path end to end. Follow local actions, reusable workflows, scripts, lockfiles, and Dependabot configuration. Inspect callers, environments, and repository rules when they affect the change and are accessible.
3. Map each job's trust boundary: triggering actor, executed code and ref, token permissions, secrets, runner, caches, artifacts, and deployment target.
4. Evaluate in this order: credential exposure and untrusted execution; trigger, ref, condition, and deployment semantics; dependency provenance; failure behavior and reproducibility; maintainability; naming and formatting.
5. When changes are requested, make the smallest coherent fix and preserve compatibility unless the task requires an interface change. Run repository-provided validators, `actionlint` when already available, and existing tests or safe validation modes for referenced scripts. Do not add review-only dependencies unless asked.
6. For a review, report findings by severity with the location, concrete failure or exposure, smallest principled fix, and evidence. Report harmless wording and casing issues separately. If there are no findings, say so. After implementation, summarize the changes and validation. In either case, identify anything that still depends on live GitHub settings.

Do not edit files for a review-only request. Treat misleading, duplicate, or compatibility-breaking names as correctness issues, not style preferences.

## Naming

Follow a coherent repository convention first. Otherwise use these defaults:

| Element                                     | Convention                                               | Example                        |
| ------------------------------------------- | -------------------------------------------------------- | ------------------------------ |
| Workflow file                               | `kebab-case` with `.yaml`                                | `api-pull-request-checks.yaml` |
| Local action metadata                       | Fixed basename with `.yaml`                              | `action.yaml`                  |
| Dependabot configuration                    | Fixed path with `.yaml`                                  | `.github/dependabot.yaml`      |
| Workflow `name`                             | Title case; optional scope uses ` / `                    | `Build` or `Service / Build`   |
| `run-name`                                  | Sentence-case phrase identifying the subject and target  | `Deploy 1.8.0 to production`   |
| Job ID                                      | Stable `snake_case` identifier                           | `build_image`                  |
| Job `name`                                  | Outcome in sentence case; include relevant matrix values | `Unit tests (Node.js 24)`      |
| Step `name`                                 | Imperative verb phrase in sentence case                  | `Upload coverage report`       |
| Owned input, output, step ID, or matrix key | Descriptive `snake_case` identifier                      | `release_version`              |
| Environment                                 | Stable repository deployment term                        | `production`                   |
| Artifact                                    | `kebab-case` name describing contents and variant        | `server-linux-amd64`           |
| Environment variable or secret              | Descriptive `UPPER_SNAKE_CASE` name                      | `AWS_DEPLOY_ROLE_ARN`          |

- Use one canonical term for each component, environment, artifact, and operation. Distinguish terms such as `publish` and `release` only when they mean different things.
- When scope adds useful distinction, use ` / ` as a namespace separator between stable scope segments and the workflow purpose, such as `<service> / <purpose>` or `<service> / <component> / <purpose>`. Do not invent scope for a top-level workflow or when no shared scope exists. Apply title case throughout, except where canonical casing differs. Do not repeat scope in jobs and steps when the workflow already makes it clear.
- Give every workflow, job, and step a name that explains the responsibility, outcome, or action without opening its commands.
- Keep workflow and job names unique across the repository. GitHub identifies required Actions checks by job name, so duplicate or changed names can make rules ambiguous or prevent a match.
- Use `run-name` and matrix values to distinguish executions, checks, and operational resource names when collisions are possible. Prefer stable identifiers to free-form attacker-controlled text.
- Create a step ID only when another expression consumes it. Prefer affirmative boolean inputs such as `publish` to inverted names such as `skip_publish`.
- Treat names, IDs, reusable workflow interfaces, environment names, concurrency groups, cache keys, and artifact names as interfaces. Find their consumers before renaming them; report an incompatible cleanup instead of breaking it.
- Apply title case and sentence case only to ordinary words. Preserve the canonical casing of products, services, projects, protocols, and acronyms, such as `GitHub Actions`, `Node.js`, `macOS`, and `npm`.
- Avoid sequence numbers, decorative emoji, redundant words, and implementation details that do not aid diagnosis.

## Correctness and reliability

- Verify events, activity types, and branch, tag, and path filters. Pull request branch filters target the base branch, and combined branch and path filters must both match.
- For merge queues, verify that required pull request checks handle `merge_group`. Required workflows must remain triggerable for every relevant change; a skipped workflow can leave its check pending.
- Verify the code and ref each job uses. Release, attestation, diff, and deployment jobs must use the intended pull request head, tested merge commit, tag, or triggering SHA.
- Trace `needs`, conditions, matrices, outputs, artifacts, and failure paths. Flag `continue-on-error`, broad `always()`, retries, or swallowed exits when they turn failure into apparent success.
- When a downstream job must report a result after a dependency fails, account for failed `needs` explicitly. Keep intentional best-effort work visible.
- Set realistic timeouts. Cancel superseded CI safely; serialize deployments, and cancel an active deployment only when interruption is safe.
- Keep checkout shallow unless history, tags, submodules, or LFS are required. Use a versioned runner label and pinned build environment when drift could change a release artifact or deployment; use `*-latest` only when testing the newest supported image is intentional.

## Dependency provenance

Treat every remote `uses:` entry as executable code with access to the job's workspace, token, network, and exposed secrets.

- Prefer GitHub-owned actions for generic GitHub operations. Use the provider's official action for authentication, signing, and deployment protocols instead of reimplementing them. A Marketplace verified-creator badge confirms identity, not implementation quality.
- Prefer a short command from the repository's existing toolchain to a convenience action with weak provenance. Use a third-party action only when it offers a concrete benefit without a suitable first-party, provider-maintained, or local alternative. Review its source, maintenance, permissions, inputs, outputs, and network behavior.
- Pin every remotely referenced action and reusable workflow to a verified full 40-character SHA from its upstream repository. Select the SHA for a stable release and add its tag on the same line, such as `# v4.2.2`.
- Compare each pin with the newest stable upstream release. Prefer the newest version compatible with the repository. Flag older pins unless their security, compatibility, or rollout constraint is documented. Treat prereleases, untagged commits, and unavailable release data as such; never guess a SHA.
- Verify that Dependabot monitors the `github-actions` ecosystem from directory `/` on a regular schedule, or that an equivalent updater covers every workflow. Review release notes and upstream changes before accepting an update; automation does not prove that checked-in pins are current.
- Pin containers by digest in privileged and release paths. Pin toolchains through version files and lockfiles; flag unbounded branches, `latest` references, and network installers in reproducible paths.
- Prefer supported setup-action caching. Derive custom keys from the platform, toolchain, and lockfiles, and never include credentials or secret material.
- Set `persist-credentials: false` on checkout unless a later authenticated Git command needs it. Prefer scoped `GITHUB_TOKEN`, GitHub App, or OIDC credentials to a personal access token.

## Security boundaries

- Declare `permissions` explicitly. Start with `permissions: {}` and grant each job only what it uses. A private checkout normally needs `contents: read`; scope write access and `id-token: write` to the job that needs them.
- Separate untrusted build and test work from secrets, write tokens, deployments, signing keys, privileged caches, and persistent self-hosted runners.
- Use `pull_request_target` only when the privileged base-repository context is essential. Privileged `pull_request_target` and `workflow_run` jobs must not check out or execute untrusted pull request code; treat downloaded artifacts as untrusted input.
- Pass attacker-controlled contexts through environment variables or action inputs instead of interpolating them into `run`. Quote shell expansions and validate values used as paths, refs, arguments, queries, or code.
- Prefer OIDC with the provider's official action to long-lived cloud credentials. Restrict the provider trust policy and protect privileged targets with GitHub environments.
- Keep secrets out of command lines, tracing, generated files, outputs, artifacts, and caches. GitHub cannot redact every transformed secret.
- Run fork pull requests on GitHub-hosted or isolated ephemeral runners, not persistent self-hosted runners.

## Maintainability

- Keep workflows focused on orchestration. Leave short commands inline; move substantial logic into versioned repository scripts that developers can run locally.
- Reuse a workflow or composite action only when repeated logic has a stable interface. Prefer local duplication to an abstraction that hides permissions, secrets, or event-specific behavior.
- Make shell and failure semantics explicit. Select the shell, quote variables, and ensure the failing command determines the step result.
- Pass values between steps through supported outputs, environment files, and artifacts; each `run` step starts a new process.
- Add comments only for non-obvious trust, pin, platform, or compatibility constraints. Keep release comments beside pinned SHAs.

Static validation cannot establish runner behavior, secrets, permissions, environment protection, repository rules, or deployment behavior. State those limits.

For version-sensitive claims, use current primary sources: GitHub's [workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), [secure use reference](https://docs.github.com/en/actions/reference/security/secure-use), [event reference](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows), [required-check guidance](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules), and [Dependabot guidance](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/auto-update-actions).
