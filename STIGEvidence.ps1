# Read-only evidence collection for Windows Server 2022 STIG manual checks.
# Makes no changes to the system. Run in an elevated PowerShell on the server being assessed:
#   powershell -ExecutionPolicy Bypass -File C:\STIG\STIGEvidence.ps1

$out = "C:\STIG\manual-evidence.txt"
"=== Administrators (V-254428) ===" | Out-File $out
net localgroup administrators | Out-File $out -Append
"=== Backup Operators (V-254241) ===" | Out-File $out -Append
net localgroup "Backup Operators" | Out-File $out -Append
"=== Local users (V-254238/244/256/267/268) ===" | Out-File $out -Append
Get-LocalUser | Format-Table Name, Enabled, LastLogon, PasswordExpires -AutoSize | Out-File $out -Append
"=== Defender (V-254248) ===" | Out-File $out -Append
Get-Service | Where-Object DisplayName -Like "*Defender*" | Format-Table Status, DisplayName -AutoSize | Out-File $out -Append
"=== Firewall (V-254265) ===" | Out-File $out -Append
Get-NetFirewallProfile | Format-Table Name, Enabled -AutoSize | Out-File $out -Append
"=== Shares (V-254260) ===" | Out-File $out -Append
Get-SmbShare | Format-Table Name, Path, Description -AutoSize | Out-File $out -Append
"=== Printers (V-254255) ===" | Out-File $out -Append
Get-Printer | Format-Table Name, Shared -AutoSize | Out-File $out -Append
"=== Time source (V-254281) ===" | Out-File $out -Append
w32tm /query /configuration | Out-File $out -Append
"=== Installed roles/features (V-254264) ===" | Out-File $out -Append
Get-WindowsFeature | Where-Object InstallState -eq "Installed" | Format-Table DisplayName, Name -AutoSize | Out-File $out -Append
notepad $out
