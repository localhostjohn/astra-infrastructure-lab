# Astra Engineering Journal

The Astra Engineering Journal records how the lab evolves: the problem being addressed, engineering decisions, implementation approach, validation, failures, measurements, lessons learned and next actions.

The journal is intentionally separate from the repository's stable reference documentation and evidence records.

- `docs/` describes the current design and operating approach.
- `evidence/` contains reviewed evidence for work that has actually been completed and validated.
- `docs/engineering-journal/` records the engineering journey, including decisions, experiments, incomplete work and reflection.
- Git history provides the change trail for the artefacts themselves.

This structure is intended to make Astra useful as an infrastructure engineering portfolio and to preserve material that may later support academic project or dissertation work. The journal itself is not a claim that any particular university or apprenticeship assessment requirement has been met.

## Journal principles

1. **Record the problem before the solution.** Explain what is being improved or investigated.
2. **Separate planned, implemented and validated states.** Do not present a design or intended test as a completed result.
3. **Prefer measurements over impressions.** Capture deployment time, detection time, recovery time, error counts, availability, resource use or other relevant metrics where practical.
4. **Record failures as useful evidence.** Failed experiments, rollback events and changed decisions are part of the engineering record.
5. **Link claims to evidence.** Completed work should reference a sanitised file under `evidence/` when suitable.
6. **Keep the repository public-safe.** Never publish credentials, tokens, private keys, live public IP addresses, personal data, employer configuration, internal names or confidential material.
7. **Explain trade-offs.** Record alternatives considered and why a choice was made rather than treating a technology choice as self-evident.

## Structure

```text
engineering-journal/
├── README.md
├── entries/
│   └── YYYY-MM-DD-short-title.md
├── decisions/
│   ├── README.md
│   ├── ADR-000-template.md
│   └── ADR-NNN-short-title.md
├── experiments/
│   ├── README.md
│   └── EXP-000-template.md
├── research-notes/
│   └── README.md
└── reflections/
    └── README.md
```

## Engineering entry workflow

A normal Astra change should move through the following path when the level of work justifies it:

```text
Problem / opportunity
        ↓
Requirements and constraints
        ↓
Options considered
        ↓
Engineering decision
        ↓
Implementation
        ↓
Validation / experiment
        ↓
Measured result
        ↓
Evidence
        ↓
Reflection and next action
```

Not every small maintenance task needs every artefact. Significant architecture, automation, resilience, networking, identity, security and operational changes should leave enough context that another engineer could understand why the change exists and how it was validated.

## Entry status vocabulary

Use these terms consistently:

| Status | Meaning |
| --- | --- |
| Proposed | An idea or planned change; implementation has not started. |
| In progress | Work has started but is incomplete or not fully validated. |
| Implemented | The change exists in the lab, but validation may still be incomplete. |
| Validated | Defined acceptance checks have been completed and recorded. |
| Superseded | A later design or decision has replaced this one. |
| Abandoned | Work was intentionally stopped; record why. |

## Suggested tags

Use plain-text tags near the top of entries when useful:

`networking`, `azure`, `linux`, `windows`, `identity`, `containers`, `automation`, `iac`, `monitoring`, `backup`, `resilience`, `security`, `dns`, `operations`.

## Evidence and measurement

Where useful, record baseline and post-change measurements such as:

- deployment or configuration time;
- number of manual steps;
- successful/failed deployment attempts;
- service detection time;
- recovery time;
- availability or outage duration;
- CPU, memory, storage and network utilisation;
- backup and restore duration;
- configuration differences or drift;
- number of administrator interventions;
- pass/fail acceptance checks.

Measurements should describe the test conditions and should never be invented to make a result look stronger.

## Academic-use notes

Potential dissertation-quality material usually requires more than implementation. Good candidates will have a clear research question, alternatives, repeatable method, measurable results, evaluation, limitations and critical discussion.

Astra can therefore act as the technical laboratory while this journal preserves the reasoning and data needed to decide later which workstream is suitable for deeper academic study.

## Current journal index

| Record | Type | Status | Summary |
| --- | --- | --- | --- |
| [2026-09-17 — Establish the Astra Engineering Journal](entries/2026-09-17-establish-engineering-journal.md) | Engineering entry | Validated | Establishes the documentation and evidence workflow for future Astra changes. |
| [ADR-001 — Use Bicep for Astra Azure Infrastructure as Code](decisions/ADR-001-use-bicep-for-azure-iac.md) | Architecture decision | Accepted | Selects Bicep as the primary IaC language for the current Azure learning workstream. |

Update this table when a record becomes important enough to act as a journal milestone.