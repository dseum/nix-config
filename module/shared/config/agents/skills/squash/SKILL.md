---
name: squash
description: User-invoked PR follow-up to assess feedback, fix problems, resolve threads, and monitor checks.
disable-model-invocation: true
---

Use the supplied PR, or find the open PR for the current branch. Confirm its
base and head. Preserve unrelated work. Invocation permits branch updates and
lease-protected pushes unless the user or repository says otherwise.

1. Read all review feedback and replies. Assess each point against the code
   and context. If evidence confirms the reported problem, make a focused fix.
   If feedback is incorrect, misses context, or is already addressed, silently
   resolve the thread. Verify that decision against the pushed code first.
   Ask if the evidence or intent is unclear. Never post PR comments or replies.
2. Review fixes with the applicable skills. Use `review-abstractions` for
   design, `review-comments` for code comments, and `review-workflows` for
   GitHub Actions. Address supported findings and run relevant checks.
3. Before you rewrite history, fetch the latest base and head. Save a recovery
   ref and record the remote SHA. Rebase and organize commits as needed.
   Check the diff, tests, and `git range-diff`. Push with
   `--force-with-lease` against the recorded SHA. Reassess if the remote moved.
   Verify the pushed head, then silently resolve threads addressed by the fixes.
4. Refresh feedback and checks for the latest pushed head. Repeat as needed.
   Wait while review or check runs are queued or running. Finish when all
   feedback is addressed, all threads are resolved, and checks have finished.
   Checks must pass unless they are legitimately skipped or inapplicable.

Fix check failures within scope. Do not weaken tests, bypass checks, dismiss
valid feedback, or change unrelated code just to finish.
If progress is blocked or monitoring stops before completion, report unfinished work.
Do not imply success or a background watcher in that case.
