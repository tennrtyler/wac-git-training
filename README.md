# WAC Git Training Sandbox

A safe playground for learning the git concepts behind Tennr Branch and WAC:
**commit (snapshot), branch (pointer), diff (comparison), merge, conflict, and rebase.**

Nothing in this repo is real. Break it freely — that's the point.

## What's in here

| File | Purpose |
|------|---------|
| `lunch-menu.md` | Easy edit target for your first branch + merge |
| `workflow.json` | Toy "referral intake" workflow config — stands in for a WAC workflow |
| `escalation-policy.md` | Toy on-call policy — the rebase target for Exercise 3 |
| `LAB.md` | The exercises, in order |
| `FACILITATOR.md` | Setup instructions + answer key (trainers only, no peeking) |
| `bootstrap.sh` | Run once by the facilitator to build the history and branches |

## Trainee quick start

```bash
git clone <REPO_URL>
cd wac-git-training
git log --oneline --graph --all
```

Then open `LAB.md` and start at Exercise 0.

## Ground rules

- You cannot break anything permanently. Git keeps everything.
- If you get stuck in a weird state: `git status` first, ask second.
- Don't let the CS folks drive your keyboard.
