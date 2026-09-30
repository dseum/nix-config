---
name: squash
description: User-invoked PR review follow-up to validate feedback, fix real issues, organize commits, and watch for more comments.
disable-model-invocation: true
---

Use the supplied PR, or find the open PR for the current branch. Confirm its
base and head, and preserve unrelated work. Invocation authorizes updating that
branch, including a lease-protected push, unless the user or repository says
otherwise.

1. Read reviews, conversation comments, and review threads with their replies.
   Check each point against current code; an outdated location may still reveal
   a real issue. Distinguish actionable feedback from duplicates, already-fixed
   points, and incorrect claims. Ask when intent is unclear.
2. Fix and verify real issues. Use `review-abstractions` for design,
   `review-comments` for changed code comments, and `review-workflows` for
   GitHub Actions changes.
3. Fetch the latest base and head, save a recovery ref, and record the remote
   head. Rebase and fold fixes into the relevant commits, or make focused new
   commits. Check the diff, `git range-diff`, and relevant tests. Push with
   `--force-with-lease` against the recorded remote SHA; reassess if it moved.
   Verify the pushed head. Never post PR comments or replies; only resolve
   threads whose concerns are addressed in the pushed code.
4. Refresh feedback and repeat. If none is actionable, wait and check again
   until review is complete, the PR closes or merges, the user stops, or the
   session ends. State when monitoring stops; do not imply a background watcher.
