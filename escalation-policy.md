# Intake Escalation Policy

Toy on-call policy for the `referral-intake` workflow. Nothing here is real —
it exists so Exercise 3 has something worth rebasing.

## Escalation ladder

| Tier | Who          | Trigger                                        |
| ---- | ------------ | ---------------------------------------------- |
| 1    | Intake queue | Fax lands in `intake-queue`                    |
| 2    | ESE on-call  | Tier 1 hasn't picked it up within the SLA      |
| 3    | Engineering  | Tier 2 escalates a workflow defect             |

## Thresholds

- Unrouted fax page threshold: 15 minutes
- Classification confidence floor: 0.80
- Alert channel: `#intake-alerts`
