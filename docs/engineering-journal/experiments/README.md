# Experiments

Use experiment records for repeatable tests that answer a specific technical question or evaluate a measurable change in Astra.

Good candidates include controlled outage tests, backup restores, deployment comparisons, alerting tests, recovery exercises, resource-usage measurements, network-path validation and configuration-rebuild tests.

## Rules

- Define the question and acceptance criteria before recording the result where practical.
- Keep the test bounded and avoid unnecessary disruption to essential services.
- Record the environment and relevant versions so the test can be repeated.
- Separate observed results from interpretation.
- Preserve failed runs when they teach something useful.
- Never invent a missing measurement.
- Link reviewed results to `evidence/` when they support a portfolio claim.

## Naming

Use sequential identifiers:

`EXP-001-short-title.md`

The identifier remains attached to the experiment even if it is rerun. Record each run date inside the experiment file or create a new experiment when the question materially changes.

Use [EXP-000](EXP-000-template.md) as the template.