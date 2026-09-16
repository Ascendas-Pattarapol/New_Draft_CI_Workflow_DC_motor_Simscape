# Check Specification: mathworks.custom.cust_0001_signal_names

## Overview

| Field | Value |
|-------|-------|
| Check ID | mathworks.custom.cust_0001_signal_names |
| Title | Signal names use TH_ prefix |
| Context | PreCompile |
| Style | Detail Style |

## Source Guideline

| Field | Value |
|-------|-------|
| Guideline ID | cust_0001_signal_names |
| Title | Signal naming convention |
| Guideline File | C:\Users\PattarapolSangaroon\My_folder\Demo_folder_workshop\cust_0001_signal_names\guideline_cust_0001_signal_names.md |

## Requirements

| ID | Statement | Inspection Targets | Priority | Notes |
|----|-----------|-------------------|----------|-------|
| CUST_0001_SIGNAL_NAMES.REQ.EMPTY | The check shall flag connected signal lines that have an empty signal name. | Signal lines | Must Have | Include branched signal segments when they carry a distinct line handle. |
| CUST_0001_SIGNAL_NAMES.REQ.PREFIX | The check shall flag connected signal lines whose signal name does not start with `TH_`. | Signal lines | Must Have | Prefix match is case-sensitive. |
| CUST_0001_SIGNAL_NAMES.EXEMPT.UNCONNECTED | The check shall not flag unconnected ports or deleted/invalid line handles. | Signal lines | Must Have | Only actual line handles are inspected. |
| CUST_0001_SIGNAL_NAMES.IP.PREFIX | The check shall provide an input parameter to configure the required signal-name prefix. | N/A | Nice to Have | Default: `TH_`. |

## Functional Design

1. Find signal line handles in the selected model or subsystem using `find_system(system, 'FindAll', 'on', 'Type', 'line')`.
2. Remove invalid line handles and lines without a destination port that can be highlighted.
3. For each remaining line, read the `Name` property.
4. Flag a violation when the name is empty.
5. Flag a violation when the name is nonempty but does not start with the required prefix.
6. Report violations using one grouped `ModelAdvisor.ResultDetail` on the checked model, with the count of connected signal lines that violate the naming rule.
7. Report a passed result when no violations are found.
