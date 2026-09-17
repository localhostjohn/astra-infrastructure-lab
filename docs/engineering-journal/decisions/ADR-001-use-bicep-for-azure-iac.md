# ADR-001 — Use Bicep for Astra Azure Infrastructure as Code

**Status:** Accepted  
**Date:** 2026-09-09  
**Tags:** `azure`, `iac`, `automation`

## Context

Astra is expanding from manually configured infrastructure into repeatable, reviewable infrastructure automation. The Azure workstream needs an Infrastructure as Code language that supports a small, controlled learning project covering resources such as virtual networks, subnets, network security groups, network interfaces and virtual machines.

The current goal is to develop Azure infrastructure automation skills without turning the lab into an unnecessarily complex platform.

## Decision drivers

- Strong alignment with Azure-native infrastructure.
- Useful learning value for Azure administration and infrastructure engineering.
- Human-readable declarative syntax.
- Ability to keep templates and parameter files in Git.
- Support for repeatable deployment and teardown.
- Low overhead for a small personal lab.
- A clear path from portal-built resources toward automated deployment.

## Options considered

### Manual Azure Portal configuration

Useful for learning individual Azure resources and troubleshooting, but weaker for repeatability, review, version control and rebuild testing.

### ARM JSON templates

Azure-native and capable, but more verbose than required for the current learning scope.

### Terraform

A mature multi-cloud IaC option with strong industry relevance. It remains a useful future learning target, particularly if Astra later needs provider-neutral or multi-cloud automation.

### Bicep

Azure-native, declarative and concise. It provides an appropriate bridge between existing Azure knowledge and repeatable infrastructure automation.

## Decision

Use **Bicep** as the primary Infrastructure as Code language for the current Astra Azure workstream.

This is a decision for Astra's present Azure learning scope, not a claim that Bicep is universally preferable to Terraform or other IaC tooling.

Initial implementations should remain small, parameterised and cost-conscious. They should support validation and teardown and should not contain live credentials or secrets.

## Consequences

### Positive

- Azure resources can be represented as version-controlled code.
- Deployments can be repeated and compared with manual deployment methods.
- Infrastructure changes become easier to review before deployment.
- Templates can support controlled rebuild and recovery experiments.
- The work aligns closely with Astra's Azure learning objectives.

### Negative / trade-offs

- Bicep knowledge is less portable to non-Azure platforms than provider-neutral tooling.
- IaC introduces its own syntax, deployment and dependency troubleshooting requirements.
- Poorly scoped templates can still create unnecessary Azure cost or exposure.
- Terraform may still need to be learned separately for broader infrastructure roles.

## Validation

The decision should be validated through a bounded Astra deployment that:

1. passes Bicep validation or equivalent pre-deployment checks;
2. uses parameters rather than embedding environment-specific values unnecessarily;
3. deploys the intended Azure resources successfully;
4. records deployment output and any errors;
5. verifies the resulting network and access behaviour;
6. supports a documented cleanup or teardown process;
7. avoids publishing secrets or sensitive values.

The eventual journal should compare manual and automated deployment effort where practical rather than assuming the automated approach is better.

## Revisit when

Reconsider the decision if Astra becomes multi-cloud, if Terraform becomes a specific learning or employment requirement, if Bicep prevents a required deployment pattern, or if a future project needs tooling that is deliberately cloud-agnostic.

## Related records

- [Infrastructure Learning Roadmap](../../roadmap.md)
- [Engineering Journal](../README.md)

Implementation evidence should be linked here only after the Bicep deployment has actually been completed and validated.