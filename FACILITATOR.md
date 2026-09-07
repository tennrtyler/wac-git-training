# Facilitator Guide

## One-time setup

1. Create an empty repo on GitHub (e.g. `tennr/wac-git-training`).
   **Don't** initialize it with a README.
2. From this directory, run:
   ```bash
   ./bootstrap.sh
   git remote add origin git@github.com:<org>/wac-git-training.git
   git push -u origin main
   git push origin routing/high-prio routing/batch-prio escalation/tiered-oncall
   ```
3. Give trainees the clone URL. That's it.

To reset between sessions: delete the GitHub repo (or force-push), re-run
`bootstrap.sh` in a fresh copy of this scaffold, push again. Trainee `pair/*`
branches from Exercise 4 can just be deleted on GitHub.

## Session flow (suggested, ~95 min)

| Time | Segment |
|------|---------|
| 0–15 | Mental model talk: snapshots not diffs, branch = pointer, Google Docs analogy and where it breaks |
| 15–20 | Exercise 0 together on the projector |
| 20–35 | Exercise 1 solo |
| 35–55 | Exercise 2 solo (this is the payoff — protect this time) |
| 55–75 | Exercise 3 solo (rebase; second-most valuable segment) |
| 75–90 | Exercise 4 in pairs (skip if short on time; it needs GitHub PRs) |
| 90–95 | Rosetta Stone: map what they just did to Tennr Branch / WAC editor |

Short on time? Cut Exercise 4, not Exercise 3. Rebase is the thing they'll
hit weekly; pair PRs they can learn on the job.

## Answer key / common stuck states

**Exercise 2 — expected conflict block in `workflow.json`:**
```
<<<<<<< HEAD
      "priority": "high",
=======
      "priority": "batch",
>>>>>>> routing/batch-prio
```
Correct resolution: whichever value they choose, with all three marker
lines deleted and valid JSON remaining. Have them pick one and say *why*
out loud — the point is that resolution is a human judgment call.

**Exercise 3 — the setup.** `escalation/tiered-oncall` forks off
`Add intake escalation policy` and carries 3 commits:

| # | Commit | Rebases |
|---|--------|---------|
| 1 | Add Tier 3 engineering escalation | cleanly |
| 2 | Page unrouted faxes after 15 minutes | **conflicts** |
| 3 | Document weekend on-call handoff | cleanly |

Meanwhile `main` gained `Relax unrouted fax page threshold to 45 minutes`,
which touches the same line as commit 2. Expected conflict block in
`escalation-policy.md`:
```
<<<<<<< HEAD
- Unrouted fax page threshold: 45 minutes
=======
- Unrouted fax page threshold: 15 minutes
>>>>>>> af02c65 (Page unrouted faxes after 15 minutes)
```
(the short id will differ in your build). Correct resolution: either
threshold, markers gone. **The teaching moment is
that `HEAD` is main's side here, not theirs** — the reverse of Exercise 2.
Ask the room which side is which before anyone edits; roughly half will get
it wrong, and that's the point. The bottom label being a commit subject
instead of a branch name is the tell that a replay is in progress.

Expect exactly one pause. If they hit a second conflict, they resolved the
first one by deleting the wrong block — `git rebase --abort` and restart.

## Facilitation reminders

- Don't let the CS folks answer everything. Cold-call the quiet half.
- When someone hits the conflict, celebrate it audibly. The emotional
  register you set for conflicts is the one they'll carry into WAC.
- Completion criteria beat attendance: everyone personally creates a
  branch, causes a conflict, resolves one, and completes a rebase.

## Common stuck states

**"I committed on main by accident"** — fine for this lab. Note it,
move on. (Or teach `git switch -c rescue-branch` if there's time.)

**"git says 'detached HEAD'"** — they checked out a commit id instead of
a branch. `git switch main` fixes it. Note that a paused rebase also puts
them in a detached-ish state; that one is normal and `git status` says so.

**Merge editor opened vim and they're trapped** — `Esc` then `:wq`.
Consider `git config --global core.editor "nano"` in setup to avoid this
entirely. This bites twice as often in Exercise 3, since
`git rebase --continue` reopens the editor.

**They resolved the conflict but the merge won't finish** — they forgot
`git add <file>` before `git commit`. `git status` shows this.

**"git rebase --continue says there's nothing to commit"** — they resolved
by deleting the whole change, so the commit became empty. `git rebase --skip`
drops it, or `--abort` and retry properly.

**Rebase panic ("I destroyed my branch")** — `git rebase --abort` if it's
still in progress; `git reflog` plus `git reset --hard <pre-rebase-id>` if it
already finished. Nothing is lost either way. Say this out loud *before* they
start Exercise 3, not after.

**They rebased and now `git push` is rejected** — expected, because rebase
rewrote the ids. Out of scope for the lab; if it comes up in Exercise 4,
that's `git push --force-with-lease`, and the reason it's `--with-lease` is
the whole "don't rebase shared branches" lesson.
