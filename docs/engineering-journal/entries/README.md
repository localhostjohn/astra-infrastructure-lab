# Engineering Entries

Use this folder for chronological records of significant Astra work. Entries should explain the engineering journey rather than duplicate stable reference documentation.

File naming: `YYYY-MM-DD-short-title.md`.

## Entry template

```markdown
# YYYY-MM-DD — Short title

**Status:** Proposed | In progress | Implemented | Validated | Superseded | Abandoned  
**Tags:** `tag`, `tag`

## Problem / opportunity

What needs to change, improve or be investigated?

## Requirements and constraints

What must the solution achieve? What cost, security, availability, hardware or learning constraints apply?

## Options considered

What realistic approaches were considered and what trade-offs were identified?

## Decision / approach

What approach was selected and why?

## Implementation

What was changed? Link to scripts, configuration or documentation rather than copying large files into the entry.

## Validation

How was the result checked? State acceptance criteria before presenting results where practical.

## Results / measurements

Record actual measurements and test conditions. Do not invent missing values.

## Evidence

Link to sanitised evidence under `evidence/` when appropriate.

## Issues and rollback

What failed, what changed during troubleshooting, and how could the change be reversed?

## Lessons learned

What did the work demonstrate?

## Next actions

What is the next bounded engineering step?
```

For a major technology or architecture choice, also create an ADR. For repeatable testing or controlled failure work, also create an experiment record.