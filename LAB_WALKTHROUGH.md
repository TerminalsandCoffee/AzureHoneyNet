# Lab Walkthrough

This walkthrough connects the original experiment's control changes to its telemetry. It distinguishes recorded observations from validation that a new run would need.

## 1. Define the boundary

The historical lab deliberately exposed Azure resources and then restricted access. Identify the resource, source, destination, and allowed operation for each control. Treat NSGs, host firewalls, service firewalls, and private endpoints as separate layers with separate tests.

Read the [infrastructure notes](./MODERNIZATION_GUIDE.md) before assuming the current Terraform code provisions every control in the original diagrams.

## 2. Establish telemetry health

Identify the required table and collection path for each host or service. Generate a known, authorized test event and verify its arrival, timestamp, and relevant fields. A quiet query is meaningful only when the collection pipeline and query scope have been checked.

The [KQL examples](./AzureHoneyNet/KQL-Query-Cheat-Sheet.md) and [rule exports](./AzureHoneyNet/Sentinel-Analytics-Rules/) are starting points for review. Inspect their joins, filters, thresholds, and required fields before relying on them as detections.

## 3. Compare the recorded windows

The [main README](./README.md#recorded-observations) preserves the March 2023 totals. Both windows span 24 hours but cover different days, and their time zone is not recorded.

Reported `SecurityEvent` and `Syslog` counts fell from 19,470 to 8,778 and from 3,028 to 25. The reported alert, incident-table, and classified-flow metrics were zero in the later window. These observations are consistent with reduced exposure; they do not measure comprehensive prevention or detection effectiveness.

Do not equate general event counts with attacks, incident-table rows with unique incidents, or empty map results with the absence of compromise. Retain each metric's exact query and counting unit.

## 4. Validate a control change

For a new, isolated lab run:

- Record configuration before and after the change.
- Test the intended administrator path and a source that should be denied.
- Check that telemetry still arrives after restrictions are applied.
- Repeat the same authorized test activity where feasible and record unrelated configuration changes.
- Review both expected alerts and benign activity that could trigger false positives.

If multiple controls change together, report the combined result and avoid attributing it to one control without separate tests.

## Evidence for a new run

| Evidence | What to record |
| --- | --- |
| Environment | Resource inventory, region, relevant software/provider versions, configuration revision |
| Observation window | Explicit time zone, start/end, and ingestion delay allowance |
| Metric definition | Exact query, source table, filters, counting unit, and any deduplication |
| Collection health | Expected sources, last event times, known test-event arrival |
| Control test | Source/destination, expected outcome, observed outcome, timestamp |
| Detection test | Input activity, expected rule, observed alert, latency, and false positives |
| Results | Sanitized exports and a calculation that reproduces each reported value |
| Limitations | Missing sources, untested paths, traffic variation, and simultaneous changes |
| Teardown | Resources removed and retained evidence |

None of this checklist implies that a new test has already been performed. It defines the evidence needed to support the next set of results.
