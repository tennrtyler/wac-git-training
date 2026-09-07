#!/usr/bin/env bash
# Builds the training repo:
#   * commit history on main
#   * two branches that conflict on the same line of workflow.json (Exercise 2)
#   * one branch 3 commits ahead of an older main, one of which conflicts
#     with main's tip, for the rebase lab (Exercise 3)
# Run once from this directory.
set -euo pipefail

if [ -d .git ]; then
  echo "Error: .git already exists here. Start from a fresh copy of the scaffold."
  exit 1
fi

git init -b main

# --- Commit 1: initial docs ---
git add README.md LAB.md FACILITATOR.md bootstrap.sh
git commit -m "Initial commit: training repo scaffold"

# --- Commit 2: add the lunch menu ---
git add lunch-menu.md
git commit -m "Add team lunch menu"

# --- Commit 3: add the toy workflow ---
git add workflow.json
git commit -m "Add referral-intake workflow config"

# --- Commit 4: a small realistic edit, so history has texture ---
sed -i.bak 's/^\([[:space:]]*"labels": \[.*\)\]$/\1, "Prior Auth"]/' workflow.json && rm -f workflow.json.bak
git add workflow.json
git commit -m "Add Prior Auth label to document classification"

# --- Commit 5: the escalation policy, base for the rebase lab ---
git add escalation-policy.md
git commit -m "Add intake escalation policy"

# --- Rebase branch: 3 commits off commit 5, the middle one conflicting ---
# Forked here on purpose: main gains one more commit below, so this branch
# ends up behind and has to be rebased forward (Exercise 3).
git switch -c escalation/tiered-oncall

# 3a: rebases cleanly (table row, away from the contested line)
awk '{ print }
     /^\| 2    \| ESE on-call/ { print "| 3    | Engineering  | Tier 2 escalates a workflow defect             |" }' \
  escalation-policy.md > escalation-policy.tmp && mv escalation-policy.tmp escalation-policy.md
git add escalation-policy.md
git commit -m "Add Tier 3 engineering escalation"

# 3b: THIS is the one that conflicts on rebase (60 -> 15 vs main's 60 -> 45)
sed -i.bak 's/^- Unrouted fax page threshold: 60 minutes$/- Unrouted fax page threshold: 15 minutes/' escalation-policy.md && rm -f escalation-policy.md.bak
git add escalation-policy.md
git commit -m "Page unrouted faxes after 15 minutes"

# 3c: rebases cleanly (appended section, away from the contested line)
cat >> escalation-policy.md <<'EOF'

## Weekend handoff

Friday 17:00 through Monday 09:00 the Tier 2 pager follows the weekend
rotation, not the weekday on-call. Hand off in `#intake-alerts` before you
drop off.
EOF
git add escalation-policy.md
git commit -m "Document weekend on-call handoff"

# --- Commit 6 on main: moves the same line branch commit 3b moved ---
git switch main
sed -i.bak 's/^- Unrouted fax page threshold: 60 minutes$/- Unrouted fax page threshold: 45 minutes/' escalation-policy.md && rm -f escalation-policy.md.bak
git add escalation-policy.md
git commit -m "Relax unrouted fax page threshold to 45 minutes"

# --- Branch A: priority -> high (forks from main's tip, so Ex 2 merge 1 is a fast-forward) ---
git switch -c routing/high-prio
sed -i.bak 's/"priority": "normal"/"priority": "high"/' workflow.json && rm -f workflow.json.bak
git add workflow.json
git commit -m "Route faxes at high priority for stat referrals"

# --- Branch B: priority -> batch (same line, different value = conflict) ---
git switch main
git switch -c routing/batch-prio
sed -i.bak 's/"priority": "normal"/"priority": "batch"/' workflow.json && rm -f workflow.json.bak
git add workflow.json
git commit -m "Batch fax routing to reduce queue noise"

git switch main

echo ""
echo "Done. History:"
git log --oneline --graph --all
echo ""
echo "Sanity check — escalation/tiered-oncall should be 3 ahead / 1 behind main:"
git rev-list --left-right --count main...escalation/tiered-oncall
echo ""
echo "Next: add your GitHub remote and push main plus all three topic branches."
echo "See FACILITATOR.md."
