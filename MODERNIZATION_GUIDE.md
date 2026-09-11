# Infrastructure Implementation Notes

The Terraform configuration and deployment helpers were added after the March 2023 experiment. They provide infrastructure reference code; the original measurements are not results from a verified deployment of the current code.

## What the code contains

| Component | Current implementation |
| --- | --- |
| Compute and network | Three VMs with public IPs, a VNet/subnet, and a subnet-associated NSG |
| NSG access mode | `hardened = false` permits inbound traffic; `true` changes that rule to deny and adds an allow rule when `admin_ip` is set |
| Key Vault access | `hardened` changes the network ACL default action; the configuration retains the `AzureServices` bypass |
| Storage | A storage account and diagnostic settings; the code does not disable its public network access |
| Telemetry | Log Analytics, connector/diagnostic declarations, and legacy VM monitoring-agent configuration |
| Automation | Bash/PowerShell helpers and GitHub workflow definitions |

The `hardened` variable controls specific network settings. It is not a declaration that every resource has been secured or tested.

## Gaps relative to the original experiment

- Private endpoints and their DNS configuration are not provisioned.
- VM host-firewall configuration is not automated.
- Storage public-access restrictions are not implemented by the `hardened` toggle.
- The code does not configure NSG flow-log collection and Traffic Analytics to reproduce the historical network metric.
- Rule imports, connector configuration, and event arrival still require verification. The presence of a resource declaration does not establish that the desired logs are collected.

## Validation status

The documentation review checked these claims against the source. It did not deploy resources, execute attack simulations, or rerun the historical measurements.

Before treating this code as deployable, validate its schema against the selected AzureRM provider, review the legacy monitoring agents and diagnostic settings against current Azure support, configure the backend, and verify the deployment in a disposable subscription. Resolve validation errors before applying a plan.

The existing CI configuration is also limited: format and plan steps permit failure, and initialization depends on backend setup. A workflow file alone does not establish a successful infrastructure or detection test.

## Evidence needed for a maintained lab

1. A recorded Terraform/provider version and successful validation output.
2. A reviewed plan and a successful deployment in an isolated subscription.
3. Positive and negative access tests for each relevant endpoint.
4. Confirmed collection from each host and service, with known test events.
5. Detection tests recording expected alerts, observed alerts, latency, and false positives.
6. Exact queries and sanitized exports for each reported metric.
7. A verified teardown and cost record.

Use the [lab walkthrough](./LAB_WALKTHROUGH.md) to organize the evidence. The [Terraform guide](./terraform/README.md) retains setup details for reference.
