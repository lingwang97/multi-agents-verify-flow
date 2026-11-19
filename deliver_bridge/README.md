# deliver_bridge

Interface directory between the design engineers and the verification team. The verification side is maintained by deliver_agent (dispatched by the leader).

- `deliver_status_<mod>_<date>.md`: verification status feedback (per module/subsystem/system: progress, issues found & fixes, design risk items).
- `design_issue_<mod>_<date>.md`: suspected design issues found by verification (symptom, reproduction, possible impact).
- `design/`: design-doc baseline and updates (placed by the design side); deliver_agent compares consistency and escalates mismatches to the user before proceeding.

Convention: append-only on both sides — never rewrite history; when an issue closes, append a status line to the original file (`open` → `fixed`/`waived` + date).
