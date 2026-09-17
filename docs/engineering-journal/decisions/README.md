# Architecture Decision Records

Architecture Decision Records (ADRs) capture significant Astra technical choices and their trade-offs.

Use an ADR when a decision affects architecture, security, networking, identity, automation, resilience, operating model or a technology that other work will depend on.

## Naming

Use sequential numbering:

`ADR-001-short-title.md`

Do not renumber old ADRs. If a decision changes, create a new ADR and mark the old one as superseded.

## Status values

- **Proposed** — under consideration.
- **Accepted** — current decision.
- **Superseded** — replaced by a later ADR.
- **Deprecated** — retained for historical context but no longer recommended.

## ADR index

| ADR | Status | Decision |
| --- | --- | --- |
| [ADR-001](ADR-001-use-bicep-for-azure-iac.md) | Accepted | Use Bicep as the primary IaC language for the current Astra Azure workstream. |

Use [ADR-000](ADR-000-template.md) as the template for new decisions.