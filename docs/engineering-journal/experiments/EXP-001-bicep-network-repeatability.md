# EXP-001 - Bicep network deployment repeatability

**Status:** Planned

## Question

Does the initial Astra Bicep network template produce a predictable, repeatable network deployment when applied more than once to the same dedicated resource group?

## Hypothesis

A second deployment of the unchanged Bicep template will converge on the already-declared VNet, subnet and NSG without creating duplicate resources or proposing unexpected configuration changes.

## Environment

- Personal Astra Azure lab only.
- Dedicated resource group.
- `infra/bicep/main.bicep` and `main.bicepparam` from the reviewed branch.
- No VM or public IP in this experiment.

## Independent variable

Deployment attempt:

1. first deployment into an empty dedicated resource group;
2. second deployment using the unchanged template and parameters.

## Measurements

For each run record:

- `az bicep build` result;
- `what-if` summary;
- deployment start/end time;
- deployment success/failure;
- resources created/modified/deleted;
- resulting VNet address space;
- resulting subnet prefix;
- NSG association state;
- any manual intervention required.

## Acceptance criteria

The experiment passes only if:

- the template builds without error;
- the first `what-if` contains only the expected foundation resources;
- the first deployment creates exactly the intended network foundation;
- the second unchanged deployment does not create duplicate resources;
- no unexpected delete action appears;
- the resulting Azure state matches the declared parameters;
- any warnings or deviations are documented rather than ignored.

## Procedure

1. Confirm the target subscription and dedicated resource group.
2. Review `main.bicepparam` for address-space conflicts.
3. Run `az bicep build`.
4. Run the first `what-if` and save/sanitise the result.
5. Deploy the template.
6. Query the VNet, subnet and NSG state with Azure CLI.
7. Run a second `what-if` with no source changes.
8. Run the second deployment.
9. Query the deployed state again.
10. Compare both runs and record manual actions, warnings and deviations.

## Results

Not yet run. Do not populate this section from expected behaviour.

## Interpretation

To be completed after real measurements exist.

## Limitations

This experiment tests a very small resource set in one Azure lab environment. Success does not prove that every future Astra module will be repeatable or that more complex state changes will be risk-free.

## Follow-up

If the foundation is validated, the next bounded experiment can add a NIC and a small Ubuntu workload, with cost/shutdown controls reviewed before deployment.
