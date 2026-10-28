# Windows Server 2022 DISA STIG Hardening Lab

I took a fresh Windows Server 2022 virtual machine, measured it against the DISA Security Technical Implementation Guide (STIG), and hardened it. Automated SCAP compliance went from **44.61% to 99.02%** (113 failed rules down to 2). I then completed all 22 manual checks in STIG Viewer, for a final checklist of **208 Not a Finding, 61 Not Applicable and 9 Open (95.85% of applicable rules)**. The 9 open findings are documented with a remediation plan in the [POA&M](POAM.md).

## Results

| Stage | Date | Score | Pass | Fail / Open | Status |
| --- | --- | --- | --- | --- | --- |
| Baseline, fresh install | Oct 13, 2026 | 44.61% | 91 | 113 | RED |
| CAT I fixed by hand | Oct 14, 2026 | 49.02% | 100 | 104 | RED |
| PowerSTIG applied | Oct 14, 2026 | 93.14% | 190 | 14 | GREEN |
| Final manual fixes + DoD certificates | Oct 19, 2026 | 99.02% | 202 | 2 | GREEN |
| Manual checks completed in STIG Viewer | Oct 28, 2026 | 95.85% | 208 | 9 | GREEN |

Every scan covered 278 rules, including 52 Not Applicable (mostly domain controller rules) and 22 manual checks the scanner cannot automate. SCC scores Pass / (Pass + Fail). The final row includes the manual checks, which is why it is lower than the last automated scan: it is the more complete number.

## Environment

| Item | Detail |
| --- | --- |
| Target | Windows Server 2022 Standard Evaluation (Desktop Experience), standalone, no domain |
| Platform | Oracle VirtualBox: 4 GB RAM, 2 vCPU, 60 GB disk |
| Firmware | UEFI with Secure Boot and TPM 2.0 |
| Scanner | SCAP Compliance Checker (SCC) 5.15 |
| Benchmark | Windows Server 2022 STIG SCAP Benchmark V2R10 |
| Automation | PowerSTIG (Server 2022 Member Server STIG data V2R8) |
| Checklist | DISA STIG Viewer 3.8.1 |
| Other tools | Local Group Policy Editor, PowerShell, auditpol, DISA InstallRoot 5.6 |

## Approach

1. **Build.** Installed Server 2022 in VirtualBox with Secure Boot and TPM 2.0, then took a clean-baseline snapshot. Snapshots were taken before every phase.
2. **Baseline scan.** Ran SCC against the Server 2022 benchmark only, so the before/after numbers stay clean.
3. **CAT I first, by hand.** Fixed all 8 high-severity findings in Group Policy: AutoPlay/AutoRun, Windows Installer elevated installs, WinRM Basic authentication, anonymous share enumeration and LAN Manager authentication level.
4. **Bulk remediation with PowerSTIG.** Compiled the STIG into a PowerShell DSC configuration ([scripts/WS2022_STIG.ps1](scripts/WS2022_STIG.ps1)), previewed it with `Test-DscConfiguration`, then applied it. Two account lockout rules failed in DSC and were set manually.
5. **Close the gaps.** Fixed the remaining findings by hand, including three newer audit rules PowerSTIG's V2R8 data did not cover, a Delivery Optimization value PowerSTIG set that V2R10 rejects, and the DoD root and cross certificates via InstallRoot.
6. **Manual checks.** Gathered evidence with a read-only script ([scripts/STIGEvidence.ps1](scripts/STIGEvidence.ps1)) and assigned every manual rule a status, comment and evidence reference in STIG Viewer.
7. **Document.** Recorded the 9 open findings, with mitigations and target dates, in the [POA&M](POAM.md).

## Problems and how I solved them

| Problem | Root cause | Fix |
| --- | --- | --- |
| VMs hung on a black screen | Hyper-V and Memory Integrity running under VirtualBox (found with `systeminfo`) | Disabled the hypervisor launch and Memory Integrity on the host, accepting a documented host security tradeoff |
| Installed scanner disappeared | VM powered off with "Restore current snapshot" checked | Reinstalled, then snapshotted and copied evidence off the VM after every phase |
| Two DSC rules failed | Lockout duration cannot be set while the lockout threshold is 0 | Set threshold, duration and reset window in order with `net accounts` |
| Delivery Optimization kept failing | PowerSTIG V2R8 wrote Bypass (100); V2R10 does not accept it | Set HTTP only (0) through Group Policy |
| Installer blocked by policy | Hardened system plus UAC Admin Approval Mode blocked a double-clicked `.msi` | Ran `msiexec` from an elevated PowerShell instead of loosening policy |
| Checklist statuses wrong after first pass | STIG Viewer's status icon cycles through values, and clicks landed on the wrong ones | Verified totals against the evidence and SCC's per-rule result, then corrected each rule |

## Open findings

9 findings remain open: 1 CAT I, 7 CAT II and 1 CAT III. Seven need enterprise infrastructure a standalone lab does not have (HIDS, central logging, file integrity monitoring, DoD time source). Two are scanner results on C:\ and HKLM permissions where effective access matches the STIG defaults; I documented them instead of rewriting system root permissions. Details and target dates are in the [POA&M](POAM.md).

## Repository contents

```
README.md                           This summary
POAM.md                             Plan of Action and Milestones for the 9 open findings
scripts/
  WS2022_STIG.ps1                   PowerSTIG DSC configuration used for bulk remediation
  STIGEvidence.ps1                  Read-only evidence collection for the manual checks
evidence/
  final-checklist-stig-viewer.cklb  Final STIG Viewer checklist: 208 NaF, 61 NA, 9 Open (sanitized)
reports/
  SCC All-Settings HTML reports     One per scan, Oct 14 to Oct 19 (sanitized)
```

SCC reports in `reports/`, by scan timestamp:

| Scan | Score | Stage |
| --- | --- | --- |
| 2026-10-14_084722 | 49.02% | After CAT I fixes |
| 2026-10-14_093107 | 93.14% | After PowerSTIG |
| 2026-10-14_100222 | 93.14% | Rescan to confirm |
| 2026-10-19_055505, 060644 | 97.06% | Manual fixes in progress |
| 2026-10-19_062714, 064211 | 97.55% | Manual fixes in progress |
| 2026-10-19_064908 | 99.02% | Final automated scan |

The 44.61% baseline HTML report was lost when a VM snapshot rollback removed the SCC install. The baseline score comes from the original scan results recorded at the time.

## Notes

- This is a lab system on a Windows Server evaluation license, not a production system. Hostname, IP address, MAC address and hardware serial number are redacted in the uploaded files.
- In this lab I acted as system owner, ISSM and Authorizing Official. In production, risk acceptance belongs to the Authorizing Official.
- STIG content and tools are published by DISA and NIWC Atlantic on public.cyber.mil.

## Skills demonstrated

DISA STIG implementation, SCAP scanning with SCC, STIG Viewer checklists, Group Policy, PowerShell and PowerShell DSC (PowerSTIG), Windows audit policy, DoD PKI certificates, vulnerability triage by CAT level, POA&M documentation, VirtualBox snapshot-based change control, and troubleshooting.

Author: Tenifayo "William" Ajiboye ([twilliam100](https://github.com/twilliam100))
