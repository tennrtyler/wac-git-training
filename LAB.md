# Git Lab — Exercises

Work through these in order. Every exercise maps to something you'll do in Tennr Branch / WAC. Commands you type are
shown in code blocks.

---

## Exercise 0 — Look around (5 min)

**Concept: commits are snapshots; history is a graph.**

```bash
git log --oneline --graph --all
```

- How many commits are on `main`?
- You should see three branches besides `main`. In a fresh clone they live on the remote, so they show up as
  `origin/routing/high-prio`, `origin/routing/batch-prio` and `origin/escalation/tiered-oncall` (the `--all` flag above
  is what makes them visible; `git branch -a` lists them too).
- Notice that `escalation/tiered-oncall` forked off an _older_ commit than the tip of `main`. We will explore that in
  exercise 3.
- Pick any commit and run `git show <commit-id>`. Git is _computing_ that diff on demand by comparing two snapshots — it
  doesn't store diffs.

---

## Exercise 1 — Your first branch and clean merge (5 min)

**Concept: a branch is a pointer, not a copy.**

1. Create a branch named after yourself and switch to it:

   ```bash
   git switch -c menu/<yourname>
   ```

1. Edit `lunch-menu.md`: add your name next to a day you like, or add a new food option.
1. Snapshot your change:

   ```bash
   git add lunch-menu.md
   git commit -m "Add <yourname>'s lunch vote"
   ```

1. Compare your branch to main:

   ```bash
   git diff main
   ```

1. Merge it back:

   ```bash
   git switch main
   git merge menu/<yourname>
   ```

1. Run `git log --oneline --graph` again. Find your commit. You should see a commit of `HEAD -> main` ahead after an
   `origin/main` commit.

**WAC corollary:** This is what happens when you make edits to your workflow or skills/agent files locally and then
merge them back into a given branch.

---

## Exercise 2 — The deliberate conflict (10 min)

**Concept: Merges frequently have conflicts - That is a normal merge outcome, not a disaster.**

Imagine two ESEs made branches that change the _same line_ of `workflow.json` in different ways:

- `routing/high-prio` — sets the fax routing priority to `"high"`
- `routing/batch-prio` — sets it to `"batch"`

These are in directly conflict with eachother - there is no programatic way to resolve this conflict. So you will!

Both branches came down with your clone, but only as _remote-tracking_ refs (`origin/routing/...`). You can think of a
remote-tracking ref like a pointer to a branch on the remote repository. It acts as a local "bookmark" representing
exactly where the remote branch stood the last time you communicated with the server.

You could merge the `origin/routing/high-prio` directly from your CLI, but let's give yourself local branches to work
with instead. Git switch will automatically create one when the name matches a remote-tracking branch:

```bash
git switch routing/high-prio   # creates a local branch tracking origin's
git switch routing/batch-prio
git switch main                # back to main, where the merges happen
```

Now merge them one at a time:

```bash
git merge routing/high-prio    # merges cleanly
git merge routing/batch-prio   # CONFLICT — good, that's expected
```

Now:

1. Run `git status`. Git tells you exactly which file is conflicted.
2. Open `workflow.json`. Find the conflict markers:

   ```
   <<<<<<< HEAD
         "priority": "high",
   =======
         "priority": "batch",
   >>>>>>> routing/batch-prio
   ```

3. Decide what the line _should_ be (you're the human — git can't decide intent). Delete the markers, keep the right
   content.
4. Finish the merge:

   ```bash
   git add workflow.json
   git commit -m "Fixed my first merge conflict"
   ```

5. Confirm with `git log --oneline --graph` — you'll see the two histories joining.

**WAC corollary:** when two people edit the same part of a workflow on different Tennr Branches, someone has to make the
call which part is technically 'correct' and keep in the merge.

---

## Exercise 3 — Rebase onto a moved main (10 min)

**Concept: rebase replays your commits onto a new base, one at a time.**

This is a situation you'll hit often in real software development work: you branched off `main`, did a few commits, and
while you were working **`main` moved** (aka other engineers commited new code). One of the commits that landed on
`main` touches the same line you touched.

The branch `escalation/tiered-oncall` is exactly that — **3 commits** that `main` doesn't have, forked from a commit
that is no longer `main`'s most recent.

1. Give yourself the local branch and look at the shape of the problem:

   ```bash
   git switch escalation/tiered-oncall
   git log --oneline --graph --all
   ```

1. Ask git precisely what each side has that the other doesn't. Use the two-dot syntax to view the changes in a commit
   range:

   ```bash
   git log --oneline main..HEAD    # your 3 commits, missing from main
   git log --oneline HEAD..main    # what main gained without you
   ```

   Write down the three commit ids (the 6 digit alphanumeric string) from the first command. You'll want them at step 7.

1. Replay your commits on top of main's current tip:

   ```bash
   git rebase main
   ```

   Git applies your 3 commits **one at a time**, oldest first. The first one lands cleanly. The second one stops.

1. Read the output, then run `git status`. It opens with _"interactive rebase in progress"_ and then shows you the
   replay list itself: which commits are `done`, and which one is still `remaining`. The rebase is a paused,
   half-finished operation that git holds your place in.
1. Resolve it. Open `escalation-policy.md` and find the markers:

   ```
   <<<<<<< HEAD
   - Unrouted fax page threshold: 45 minutes
   =======
   - Unrouted fax page threshold: 15 minutes
   >>>>>>> af02c65 (Page unrouted faxes after 15 minutes)
   ```

   Two things to notice:
   - `HEAD` is now **main's** side, not yours. During a rebase, main is the base you're landing on, so the sides are
     swapped from what you saw in Exercise 2.
   - The bottom label is the _commit being replayed_ (id + subject), not a branch name, because git is mid-replay. Your
     id will differ from the one above as commit ids are per-repo.

   Delete the markers and leave the threshold you'd actually want.

1. Hand the resolution back to git and let the replay finish:

   ```bash
   git add escalation-policy.md
   git rebase --continue
   ```

   Git may open an editor with the original commit message. It's already correct — save and close. (Trapped in vim?
   `Esc` then `:wq`.)

   The third commit replays cleanly and the rebase finishes.

1. Look at what you got:

   ```bash
   git log --oneline --graph --all
   ```

   Your 3 commits now sit in a **straight line** on top of `main` — no merge commit, no fork in the graph. Compare the
   commit ids to the ones you wrote down in step 2: they're **different**. Rebase doesn't move commits, it copies them
   onto a new base.

1. Merge back. Because the branch is now directly on top of `main`, there's nothing to reconcile:

   ```bash
   git switch main
   git merge escalation/tiered-oncall    # fast-forward — no merge commit
   ```

**Easy Revert:** at any point during a paused rebase, `git rebase --abort` puts you back exactly where you started,
conflict and all undone. Try it on purpose once, then redo the rebase.\
It's good to know you can easily reverse a failed rebase as it might seem daunting on first glance!

**Merge or rebase?** You technically could resolve the situation in Exercise 3 via a Rebase or a Merge. Both will get
main's changes into your branch.\
A merge keeps the fork visible and adds a merge commit; a rebase makes history linear as if you'd started from main's
tip all along. The linear rebase is easier to read but the price is rewritten commit ids. This means you don't want to
rebase a branch other people have already pulled. You end up with two distinct commit IDs representing the same code.
History doesn't explicitly link these duplicate commits and you end up in a situation where the merge conflict you
resolved comes right back. Additionally, new work can be anchored on an unreachable branch.

You don't need to understand exaclty why (although please ask Claude if you're curious). What you should remember is the
general rule of thum to never rebase shared branches which basically means _don't rewrite history someone else is
standing on without telling them._

**WAC corollary:** When someone else pushes changes while you're working on an existing branch, this is how you catch up
without a merge commit for every sync.\
Generally, you will always want to rebase onto the current main **before** asking for any reviews.

---

## Exercise 4 — (time permitting) Pair conflict on GitHub (20 min, pairs)

**Concept: remotes — your history and the shared history can diverge.**

With a partner:

1. Both of you branch off `main` (`git switch -c pair/<yourname>`).
2. Both edit the **same line** — the `"destination"` value in `workflow.json`. Pick different values.
3. Both commit and push:

   ```bash
   git push -u origin pair/<yourname>
   ```

4. Both open pull requests on GitHub. After your push, you should see a github hook with a link to creating your PR.
   E.g.:\
   `remote: Create a pull request for 'pair/tyler' on GitHub by visiting:`

   `remote:      https://github.com/tennrtyler/wac-git-training/pull/new/pair/tyler`\
   If you can't find this link for some reason, go view the Github repo for this exercise. You will see a banner at the
   top with a "Compare & pull request" button.

5. Merge the first PR. Watch the second one flip to "has conflicts."
6. The second person resolves it — on GitHub's web editor, or locally with the Exercise 2 recipe, or by rebasing with
   the Exercise 3 recipe — and merges.

**WAC mapping:** this is why review-then-merge exists as a flow, and why the second merge sometimes needs a human even
when the first was clean.

---

## Done?

You have now personally: created branches, read diffs, done a clean merge, caused a conflict, resolved one, and rebased
a stale branch onto a moved main. That's the entire concept that Tennr Branch is built on.

Want more? https://learngitbranching.js.org/ — the later levels cover interactive rebase, cherry-pick, and reset/revert.
