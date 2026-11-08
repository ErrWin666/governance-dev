#requires -RunAsAdministrator
<#
.SYNOPSIS
  Layer-2 protection for governance files (Session #19).
  Removes inheritance; grants AA read-only, Administrators + SYSTEM full control.
  Layer 1 is policies/p4_require_evidence.rego (P4-GOVERNANCE-FILE).

.PARAMETER Restore
  Recovery path: re-enables inherited ACLs (icacls /reset) so AA regains write.
  Edit the files, then re-run WITHOUT -Restore to re-lock.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\apply-governance-acl.ps1
  powershell -ExecutionPolicy Bypass -File .\apply-governance-acl.ps1 -Restore
#>
param([switch]$Restore)

$repo = 'C:\governance-dev'
$files = @(
  "$repo\policies\gate.sh",
  'C:\Users\AA\AppData\Roaming\devin\config.json',
  'C:\Users\AA\AppData\Roaming\devin\mcp_config.json'
)
$files += (Get-ChildItem "$repo\policies\*.rego" -File).FullName
$dirs = @("$repo\policies\.governance")

foreach ($f in $files) {
  if ($Restore) { icacls $f /reset | Out-Null }
  else          { icacls $f /inheritance:r /grant:r 'AA:R' /grant:r 'Administrators:F' /grant:r 'SYSTEM:F' | Out-Null }
  Write-Host ("{0} {1}" -f ($(if ($Restore) {'RESET '} else {'LOCKED'}), $f))
}
foreach ($d in $dirs) {
  if ($Restore) { icacls $d /reset /T | Out-Null }
  else          { icacls $d /inheritance:r /grant:r 'AA:(OI)(CI)(R)' /grant:r 'Administrators:(OI)(CI)(F)' /grant:r 'SYSTEM:(OI)(CI)(F)' /T | Out-Null }
  Write-Host ("{0} {1} (+children)" -f ($(if ($Restore) {'RESET '} else {'LOCKED'}), $d))
}

Write-Host "`nEffective ACLs:"
foreach ($f in ($files + $dirs)) { icacls $f | Select-Object -Skip 0 }

if (-not $Restore) {
  Write-Host "`nVerify layer 2 as AA (should say Access is denied):"
  Write-Host '  echo x >> C:\governance-dev\policies\gate.sh'
}
