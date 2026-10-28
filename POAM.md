# POA&M: Windows Server 2022 STIG Lab

Plan of Action and Milestones for the 9 findings open after the October 28, 2026 checklist (208 Not a Finding, 61 Not Applicable, 9 Open). CAT I is scheduled first. All target dates fall before the Windows Server evaluation license expires (about April 11, 2027).

| Vuln ID | CAT | Weakness | Mitigation in place | Planned remediation | Target date | Status |
| --- | --- | --- | --- | --- | --- | --- |
| V-254240 | I | Admin account used to browse the internet | Standard account `labuser` created; admin web use limited to DISA and Microsoft tool downloads | Write a local rule banning admin browsing; download as `labuser` and copy files in via the shared folder | 2026-11-04 | Open |
| V-254251 | II | C:\ permissions differ from the STIG default list (extra Synchronize flag, entry order) | Effective access verified identical to STIG defaults with `icacls` | On a test snapshot, reset C:\ to the exact STIG entries with `icacls`, rescan, keep or roll back | 2026-11-11 | Open |
| V-254254 | II | HKLM permissions flagged; HKLM\SECURITY not yet reviewed | SOFTWARE and SYSTEM verified against STIG defaults with `Get-Acl` | Review HKLM\SECURITY in regedit; correct it or document as a false positive | 2026-11-11 | Open |
| V-254245 | II | No application allowlisting | Defender Antivirus running; installs require elevation | Build AppLocker deny-by-default rules on a test snapshot, run in audit mode, then enforce | 2026-12-09 | Open |
| V-254249 | II | No host-based intrusion detection or prevention | Defender Antivirus and Firewall enabled on all profiles | Deploy a Wazuh agent reporting to a Wazuh manager VM; confirm whether it meets the HIDS/HIPS check | 2027-01-15 | Open |
| V-254259 | II | No file integrity monitoring | None | Wazuh file integrity monitoring on system file paths, with weekly baseline comparison | 2027-01-15 | Open |
| V-254294 | II | Audit logs not backed up to a separate system | Logs kept locally; VM snapshots | Forward Windows event logs to the Wazuh manager VM | 2027-01-15 | Open |
| V-254295 | II | Audit logs not offloaded | Logs kept locally | Same Wazuh log collection, at least weekly | 2027-01-15 | Open |
| V-254281 | III | Time syncs to time.windows.com, not a DoD source | Synced to Microsoft's public time service | No DoD network access; if connected, set NtpServer to a DoD time source per the fix text | Review 2027-04-01 | Risk accepted |

**Risk acceptance:** in this lab I act as system owner, ISSM and Authorizing Official. In production, only the Authorizing Official can accept risk.

**Note on Wazuh:** the Wazuh agent runs on Windows and provides log collection, file integrity monitoring and active response ([Wazuh documentation](https://documentation.wazuh.com/4.10/getting-started/components/wazuh-agent.html)). Whether it satisfies the DoD HIDS/HIPS requirement has not been confirmed.
