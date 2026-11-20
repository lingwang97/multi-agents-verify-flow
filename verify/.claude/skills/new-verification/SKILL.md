---
name: new-verification
description: Intake procedure for a brand-new verification requirement. The leader analyzes the request, proposes the standard pipeline (spec2json → json2env → dev/debug → review → deliver) with per-stage scope, inputs and skip hints, then asks the user to adopt, skip named stages, or override. Use when a new module/feature-set/level verification effort starts, or when the user invokes /new-verification.
---

Run the new-requirement intake procedure canonized in `docs/ops/multi_agent_ops.md` §8 for the requirement below: trigger test (new effort vs continuation), light state check (arch §0, taskboard, `docs/features/<mod>/`), personalized six-stage plan table with skip hints, AskUserQuestion decision (adopt / skip named stages / custom), then record the decision + plan in `docs/memory/leader_taskboard.md`. Existing gates stay in force — the pipeline never auto-executes.

Requirement: $ARGUMENTS
