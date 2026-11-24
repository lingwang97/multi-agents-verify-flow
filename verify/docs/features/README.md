# docs/features

Verification feature decomposition and progress, per module (dev_agent; directories are created on first touch by the leader or dev_agent).

- `<mod>/<mod>_features.md`: feature list — ID, description, planned verification method (property assertion / uvm_component check / reference model / directed testcase / random cases; add `gray-box (RTL access approved <date>)` when the point relies on design internals, ops §1), status (`proposed` → `confirmed` → `in-dev` → `done`). **A `proposed` list must be user-reviewed and confirmed before development starts.**
- `<mod>/PROGRESS.md`: development progress (per-feature status, self-check results, blockers).

Division of labor vs memory: this directory records *what is being done and where it stands*; lessons learned (the why, the pitfalls) go to `docs/memory/dev/<mod>.md`.
