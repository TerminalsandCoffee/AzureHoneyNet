# Azure Honeynet: Security Controls and Detection

A cloud security lab exploring how network exposure affects observed telemetry in Microsoft Sentinel. It combines a documented Azure honeynet experiment, KQL examples, alert-rule exports, and Terraform reference code.

The central question: **what changes in the logs after restricting access, and what can those changes actually tell us?**

## Start here

- [Lab walkthrough](./LAB_WALKTHROUGH.md): follow the control change, telemetry, and evidence limitations.
- [KQL examples](./AzureHoneyNet/KQL-Query-Cheat-Sheet.md): explore authentication, host, and Azure service events.
- [Analytics rule exports](./AzureHoneyNet/Sentinel-Analytics-Rules/): review queries, thresholds, and mappings before adapting them.
- [Terraform scope](./MODERNIZATION_GUIDE.md): understand what the later infrastructure code covers and what still needs work.

## The experiment

The original March 2023 lab used two Windows VMs and one Linux VM, a virtual network and network security group (NSG), Log Analytics, Microsoft Sentinel, Key Vault, and a storage account.

The documented initial configuration exposed resources to internet traffic. The later configuration restricted inbound access to the administrator's workstation and applied host/service firewall controls and private endpoints. Two separate 24-hour windows were recorded before and after that change.

These are historical observations. The Terraform code added later is a reference implementation and does not establish an exact reproduction of that experiment. In particular, it does not provision private endpoints or configure the VM host firewalls shown in the original write-up.

### Documented architecture

| Before access restrictions | After access restrictions |
| --- | --- |
| ![Original exposed lab architecture](https://i.imgur.com/aBDwnKb.jpg) | ![Original hardened lab architecture](https://i.imgur.com/YQNa9Pp.jpg) |

These diagrams describe the original lab, rather than a verified deployment of the current Terraform configuration.

## Recorded observations

| Window | Start | End |
| --- | --- | --- |
| Before | March 15, 2023 17:04:29 | March 16, 2023 17:04:29 |
| After | March 18, 2023 15:37 | March 19, 2023 15:37 |

The original write-up does not state the time zone. Each window spans 24 hours, but the windows are on different days.

| Reported metric | Before | After | Interpretation |
| --- | ---: | ---: | --- |
| `SecurityEvent` | 19,470 | 8,778 | Reported Windows security-event count; about 54.9% lower. This is not a count of confirmed attacks. |
| `Syslog` | 3,028 | 25 | Reported Linux syslog count; about 99.2% lower. Exact authentication filters must be retained to classify these records. |
| `SecurityAlert` | 10 | 0 | No alerts were reported for the second window. This does not measure detection coverage. |
| `SecurityIncident` | 348 | 0 | Reported incident-table metric. The historical query is not retained with the totals, so 348 should not be presented as 348 distinct incidents. |
| `AzureNetworkAnalytics_CL` | 843 | 0 | Reported metric for allowed flows classified as malicious by the lab's query; no matches were reported in the second window. |

The totals above are preserved from the [original experiment record](./AzureHoneyNet/README.md). The repository includes map/query artifacts, but not a complete raw event export and exact metric-query set sufficient to independently recalculate every total. This documentation update did not rerun the experiment.

### What the results support

The lower reported counts are consistent with reduced exposure after access restrictions. They are useful observations about this lab and these time windows.

They do not establish that all malicious traffic was blocked, that the environment was free of compromise, or that the detections cover every attack. Internet traffic varies, legitimate activity changes event volume, and a broken collection pipeline can also produce fewer records. Multiple controls changed together, so the measurements do not isolate the effect of any one control.

For incident metrics, distinguish table rows from unique incidents: Sentinel adds a new `SecurityIncident` record when an incident is created or updated. See [Microsoft's incident-metrics guidance](https://learn.microsoft.com/en-us/azure/sentinel/manage-soc-with-incident-metrics).

### Historical attack maps

![Allowed flows classified as malicious in the original lab](https://i.imgur.com/1qvswSX.png)

![Linux authentication failures in the original lab](https://i.imgur.com/G1YgZt6.png)

![Windows authentication failures in the original lab](https://i.imgur.com/ESr9Dlv.png)

The original post-change map queries returned no results. That describes query output for the observed window, not the absence of all malicious activity.

## Lessons for control validation

- **Test the access boundary.** Verify both the intended administrator path and an unauthorized source after changing network rules.
- **Verify collection before interpreting a quiet dashboard.** Confirm recent records and expected test events from each required source.
- **Treat detection content as lab material.** Review query semantics, prerequisites, thresholds, false positives, and ATT&CK mappings before reuse. The exported rules are not validated for another environment simply because they can be imported.
- **Check public and private access separately.** A private endpoint provides a private path; public endpoint access still needs explicit configuration. See [Azure Storage network security](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security-overview).
- **Keep evidence reproducible.** Save configuration changes, exact queries, time zones, filters, collection-health checks, and sanitized results together.

## Repository contents

| Path | Purpose |
| --- | --- |
| [AzureHoneyNet/](./AzureHoneyNet/) | Historical experiment record, KQL, maps, and exported rules |
| [Attack-Scripts/](./AzureHoneyNet/Attack-Scripts/) | Lab scripts for generating test activity; review targets and behavior before running |
| [Vulnerability-Management/](./AzureHoneyNet/Vulnerability-Management/) | Scripts demonstrating changes to legacy protocol settings |
| [terraform/](./terraform/) | Later Azure infrastructure reference code |
| [scripts/](./scripts/) | Terraform deployment helpers |
| [.github/workflows/](./.github/workflows/) | Terraform validation and scanning workflow definitions |

## Working with the infrastructure

Read the [implementation scope and gaps](./MODERNIZATION_GUIDE.md) before using the [Terraform guide](./terraform/README.md). The current code is not an end-to-end validated reconstruction of the historical lab. Workflow definitions and deployment helpers are not evidence of a successful deployment or complete telemetry collection.

Use an isolated, authorized lab subscription with disposable data and a defined teardown plan. The exposed mode intentionally permits inbound traffic and creates billable resources. Review the configuration and plan before applying changes.

For a new run, use the [walkthrough's evidence checklist](./LAB_WALKTHROUGH.md#evidence-for-a-new-run) to record results that another reviewer can assess.
