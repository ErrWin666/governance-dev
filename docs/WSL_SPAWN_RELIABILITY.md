# WSL Gate-Spawn Reliability: `STATUS_DLL_INIT_FAILED` (0xC0000142) Findings

Research target: intermittent `wsl.exe` spawn failure (Windows exit code `-1073741502` =
`0xC0000142` = `STATUS_DLL_INIT_FAILED`) in the PreToolUse/PostToolUse governance hook —
2 `wsl.exe` process creations per tool call, `fail_closed=true`, 15 s timeout, on
Windows 11 + WSL2 (Ubuntu-24.04) with Docker Desktop co-resident.

Each finding is tagged **[DOC]** (documented in a primary/credible source) or
**[INF]** (inference from the documented evidence applied to our environment).

---

## 1. What 0xC0000142 means at process creation

`0xC0000142` = `STATUS_DLL_INIT_FAILED`: `CreateProcess` succeeded — the loader
started the image — but a DLL's `DLL_PROCESS_ATTACH` (or console-subsystem init)
returned failure, so the process exits before `main()`. That is exactly why
`gate.sh` never logs: the Linux side is never reached; the failure is on the
Windows side of `wsl.exe` itself.

- [DOC] Definition and mechanics (CreateProcess vs. loader responsibility):
  https://learn.microsoft.com/en-us/archive/blogs/winsdk/what-is-up-with-the-application-failed-to-initialize-properly-0xc0000142-error
- [DOC] `wsl.exe` itself is a documented victim: scheduled-task runs of `wsl.exe`
  return `-1073741502` with `Application Popup` Event ID 26
  (`wsl.exe - Application Error ... 0xc0000142`):
  https://github.com/microsoft/WSL/issues/6707
  and https://stackoverflow.com/questions/66727315/

### Documented root causes, ranked by fit to our evidence

| Rank | Cause | Evidence for / against | Sources |
|---|---|---|---|
| 1 | **Console/conhost init failure at spawn.** `wsl.exe` is a console-subsystem client; `0xc0000142` is the specific code produced "when conhost fails to launch before the process finishes launching" (D. Howett, Windows Terminal team). A per-spawn, load-correlated failure fits conhost allocation failing intermittently under ~335 processes / low memory. | Strong: failure is per-spawn, transient, machine under load. The IDE spawns hooks headlessly — console attach/alloc on every call is a fragile path. | [DOC] https://github.com/microsoft/WSL/issues/5448 (DHowett comment); [DOC] bundled-ConPTY variant producing per-spawn `0xc0000142` on `wsl.exe`, scaling with spawn count: https://github.com/zed-industries/zed/issues/62754 |
| 2 | **Memory/commit pressure.** 2.7 GB free of 16 GB. Commit-limit pressure makes early-process-init allocations fail → `STATUS_DLL_INIT_FAILED`. Separately, WSL itself wedges under memory pressure (`vmbus_alloc_ring` failure: existing sessions work, *new* sessions/`wsl.exe` hang). | Strong: matches "intermittent, system-wide, worse under load". | [DOC] https://devblogs.microsoft.com/oldnewthing/20130628-00/?p=3963 ; [DOC] https://github.com/microsoft/WSL/issues/40795 |
| 3 | **Desktop heap exhaustion.** Classic documented cause of `0xC0000142` in `user32.dll`. Each process spawn consumes desktop heap in its window station; non-interactive window stations get only the 3rd `SharedSection` value (default ~512 KB) per desktop. Hooks spawned by the IDE normally share the interactive `WinSta0\Default` desktop, so this is a contributing amplifier rather than a standalone cause — but if the IDE/hook host runs in a non-interactive station, it jumps to rank 1. | Medium: consistent with "worse with more processes"; needs Event ID 26 caption + window-station check to confirm. | [DOC] https://learn.microsoft.com/en-us/archive/blogs/ntdebugging/desktop-heap-overview ; [DOC] https://learn.microsoft.com/en-us/troubleshoot/windows-server/performance/desktop-heap-limitation-out-of-memory ; [DOC] https://learn.microsoft.com/en-us/previous-versions/troubleshoot/windows/win32/user-32-kernel-32-not-initialize |
| 4 | **AV/EDR injection or AppInit_DLLs failure.** Injected DLLs that fault during `DLL_PROCESS_ATTACH` produce exactly this code; AV products are documented to break WSL components (Avast disabled `wslservice.exe`). | Medium-low: would likely fail more consistently per-binary, but EDR hooking under resource contention can be intermittent. | [DOC] https://github.com/microsoft/WSL/issues/11582 ; [DOC] `LoadAppInit_DLLs` mechanism: https://thegeekpage.com/how-to-solve-application-error-0xc0000142-in-windows-10/ |
| 5 | **IRPStackSize.** Real registry knob (`HKLM\SYSTEM\CCS\Services\LanmanServer\Parameters\IRPStackSize`, range 11–50, KB 285089) but it governs *server-side SMB IRP stacks* on XP/2003-era systems. It is essentially auto-managed on Windows 11 and is **not** a documented cause of local `CreateProcess`/`wsl.exe` init failure. | Weak for this symptom; listed only because it circulates in folklore. | [DOC] https://learn.microsoft.com/en-us/troubleshoot/windows-server/performance/desktop-heap-limitation-out-of-memory (context); KB 285089 via https://www.scribd.com/document/967545080/Petrel-2019-1-Installation-Guide-11 |

### Documented mitigations for the 0xC0000142 class

- [DOC] **Desktop heap**: edit `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems\Windows`,
  `SharedSection=a,b,c` — raise **c** (non-interactive window-station heap; e.g. 512→768/1024+ KB)
  and/or **b** (interactive heap). Requires reboot. Microsoft cautions to raise only when needed.
  https://learn.microsoft.com/en-us/troubleshoot/windows-server/performance/desktop-heap-limitation-out-of-memory
- [DOC] **Confirm first**: `Application` log → `Application Popup` **Event ID 26** names the exact
  faulting image (`wsl.exe` vs `conhost.exe` vs `wslhost.exe`) — observed doing exactly this in
  microsoft/WSL#6707. WER/`.wer` files give the same without a dialog.
- [INF] **Reduce spawn-count pressure**: every avoided `wsl.exe` spawn avoids the fragile
  conhost/DLL-init window entirely (see §4).
- [INF] **Memory**: enlarge/let Windows manage the pagefile, cut resident process count; also
  bounds WSL VM memory via `.wslconfig` `memory=` so the utility VM doesn't squeeze the host.

---

## 2. WSL-side failure modes that produce "hook spawn fails but manual WSL works"

All of these are documented states where `wsl.exe` *process creation* or *new-session
creation* fails while previously-open sessions keep working — matching "script log
shows nothing; WSL works when I try it":

- [DOC] **hvsocket new-session transport death**: after `wsl --terminate` and after
  Modern Standby resume, every new session fails (`UtilAcceptVsock: accept4 failed 110` →
  client sees `Wsl/Service/E_UNEXPECTED` or `0x8007274c`) while the distro still reports
  `Running` and in-VM services keep serving. Recovery requires `wsl --shutdown`
  (+ Docker Desktop restart). https://github.com/microsoft/WSL/issues/41286 ,
  corroborated by https://github.com/microsoft/WSL/issues/40795
- [DOC] **Sustained headless `wsl.exe` churn wedges session creation**: ~80 `wsl.exe`
  launches in ~22 min preceded a transport wedge; stranded in-VM `Relay` processes that
  never exit accumulate (same issue, section C). Two spawns per tool call over a long
  IDE session reaches this volume. https://github.com/microsoft/WSL/issues/41286
- [DOC] **Concurrent-spawn race crashes the Interop server**: ~20 `wsl.exe` processes
  within ~200 ms plus client-side kills → `InteropServer` crashes with broken-pipe
  `ResultException`; every new session then hangs until `wsl --terminate`. Killing a
  `wsl.exe` mid-handshake is the documented trigger.
  https://github.com/openai/codex/issues/46703 → https://github.com/microsoft/WSL/issues/41592
- [DOC] **Another IDE hit the same class**: Claude Desktop's file index spawning one
  `wsl.exe --exec realpath` per directory on session switches drove spawn round-trip
  latency 0 s → 6–7 s and wedged the WSL service. https://claudeissues.com/issue/104718
- [DOC] **Idle teardown creates a cold-start window**: default timers — instance idle
  ~8–15 s, then `vmIdleTimeout=60000` (60 s) shuts the whole utility VM. Any `wsl.exe`
  arriving during VM boot or during teardown is racing a moving target.
  https://learn.microsoft.com/en-us/windows/wsl/wsl-config ;
  https://github.com/microsoft/WSL/discussions/8659
- [INF] **Our 15 s timeout is an amplifier, not just a limit**: cold-start `wsl.exe`
  after idle can take several seconds; if the IDE kills the process at 15 s while the
  session handshake is in flight, that is precisely the "client disconnects before
  reply" pattern that crashes Interop/strands Relays in the issues above — i.e., the
  hook configuration can *manufacture* the wedge it then keeps hitting.

---

## 3. Why the WSL virtual switch is rebuilt every ~20–30 min

- [DOC] The create/delete NIC + port cycle on switch `WSL` every few minutes (up to
  ~30 min gaps) is a long-standing reported behavior:
  https://github.com/microsoft/WSL/issues/7178
- [DOC] Recurring `Microsoft-Windows-Hyper-V-VmSwitch` Event ID **285**
  (`IOCTL_ENUM_NIC_COUNT_EX ... took too long`, `OID_GEN_STATISTICS` on
  `WSL (Hyper-V firewall)` NIC) correlates with WSL VM restart cycles:
  https://github.com/microsoft/WSL/issues/40363
- [DOC] **Mechanism**: when the last short-lived session ends, the host session manager
  powers the instance/VM down; the next spawn rebuilds it → VmSwitch logs port
  delete/create each cycle. With per-call `wsl.exe` spawns and gaps between tool calls,
  this maps directly onto our cadence. https://blog.csdn.net/bobodadao/article/details/161447650 (log-level walkthrough)
- [DOC] Docker Desktop adds noise on top: "resource saver" mode freezes/unfreezes its
  distros and is reported to stall unrelated WSL sessions
  (https://github.com/microsoft/WSL/issues/12830 discussion; docker/for-win#14656),
  and its `docker-desktop` distro shares the same utility VM and WSL switch.
- [INF] So the ~20–30 min rebuild is most plausibly the **idle-VM teardown/recreate loop**
  (possibly kicked by Docker Desktop periodic activity), not a Windows Update artifact.
  Each rebuild is a window where a `wsl.exe` spawn can lose the race.
- [DOC] Mitigations documented in those threads and MS docs:
  - `.wslconfig`: `[wsl2] vmIdleTimeout=-1` — never idle-tear-down the VM
    (https://learn.microsoft.com/en-us/windows/wsl/wsl-config);
    `[experimental] autoMemoryReclaim=disabled` (per #40363 workaround).
  - Keep one long-lived process inside the distro: `wsl -d Ubuntu-24.04 -- sleep infinity`
    (workaround blessed in #40363 and widely used: https://guidov.github.io/2024/09/15/wsl2-keep-alive/ ,
    https://lumadock.com/tutorials/hermes-wsl2-gateway-disconnecting).
  - Networking mode: `networkingMode=mirrored` replaces the ICS/NAT `WSL` switch with
    FSE mirrored switches — different churn profile; conversely if mirrored mode is
    already on, switching back to `nat` removes the per-interface FSE switch
    create/delete events. Either is a .wslconfig toggle + `wsl --shutdown`.
    https://learn.microsoft.com/en-us/windows/wsl/networking

---

## 4. Execution-placement options for the gate (per-call reliability)

What `gate.sh` actually needs: `bash`, `jq`, `python3` (`exec_analyze.py`), `sha256sum`,
`find/sort/xargs/awk/grep`, `opa eval`. Inventory of what runs where:

- [DOC] **OPA ships a first-class Windows binary**: `opa_windows_amd64.exe` is a
  standard release artifact (also `winget install open-policy-agent.opa`); `opa eval`
  works identically. https://github.com/open-policy-agent/opa/releases ,
  https://pkgs.win/packages/o/open-policy-agentopa/
- [DOC] **Git for Windows bundles** bash, coreutils, gawk, sed, grep, perl, curl —
  but **not** `jq` and **not** `python` (explicit maintainer decision):
  https://github.com/git-for-windows/git/issues/3374 . Both are one `winget install`
  (`jqlang.jq`, `Python.Python.3.13`) away as native `.exe`s usable from Git Bash.
- [DOC] Rego evaluation needs no Linux syscall surface — the gate's only true Linux
  dependency is the filesystem *layout* (`/mnt/c/...` paths), which translates
  mechanically (`/c/governance-dev/...` works in Git Bash already).
- [INF] **Native Git-Bash gate** (Git Bash + `jq.exe` + `python.exe` + `opa.exe`):
  removes **all** VM-boundary crossings per call — no `wsl.exe` spawn, no conhost
  lottery, no hvsocket/Interop/Relay exposure, no idle-VM race, and it's faster.
  Costs: re-verify Rego/sha256 behavior on `C:/` paths, keep a `.gitbash` variant of
  `gate.sh` (there is already a `gate.sh.gitbash.bak` in the repo suggesting prior
  work in this direction), and own the two extra tool installs.
- [DOC] **Keep-WSL-warm variant**: if the gate must stay Linux-side, hold the distro
  open with an anchor session (`wsl.exe -d Ubuntu-24.04 --exec /bin/sh -c "exec sleep infinity"`,
  supervised/registered at logon) plus `vmIdleTimeout=-1`. Documented patterns incl.
  restart-on-death supervision: https://github.com/gitcommit90/1Helm ,
  https://github.com/Opendray/opendray/blob/main/scripts/install-windows.ps1
- [DOC] **Persistent channel**: run the policy evaluation as a long-lived in-distro
  service and have the Windows hook do a `localhost` HTTP call (`opa run --server`,
  `localhostForwarding=true` by default) — converts 2 VM-boundary *process spawns* per
  call into 2 TCP loopback calls; also makes "service down" detectable separately from
  "deny". https://learn.microsoft.com/en-us/windows/wsl/wsl-config (localhostForwarding)
- [INF] **Retry wrapper**: wrap the `wsl.exe` invocation in a small Windows-side
  launcher that retries **only** on infrastructure codes (`-1073741502`/`0xC0000142`,
  `E_UNEXPECTED`, `0x8007274c`, timeout-with-no-output) with backoff (e.g. 0.5 s / 2 s /
  5 s, ~3 attempts inside the 15 s budget), while passing through real policy exits
  (0/2) untouched. Important subtlety from #41286: *killing* a mid-handshake `wsl.exe`
  worsens the wedge — retry must not spawn a second client while the first is still
  inside session setup, and repeated failures should trip a cooldown rather than hammer.
- [DOC] Claude Code hook semantics relevant here: non-2 exit ≠ verdict; with
  `onFailure:"block"` a spawn failure already blocks (fail-closed preserved), but every
  transient becomes a full tool-call denial — retries inside the wrapper convert most of
  them into silent successes. https://code.claude.com/docs/en/hooks

---

## 5. Ranked mitigation plan (effort ↑ impact)

| # | Action | Effort | Expected impact |
|---|---|---|---|
| 1 | **Keepalive anchor + `.wslconfig`**: at logon run `wsl.exe -d Ubuntu-24.04 --exec bash -c "sleep infinity"`; set `[wsl2] vmIdleTimeout=-1`, `autoMemoryReclaim=disabled`. `wsl --shutdown` once to apply. | ~30 min, no code | Eliminates the idle-teardown cold-start race and most VmSwitch rebuilds; keeps session transport warm. Highest value/effort. |
| 2 | **Confirm the faulting binary**: Application log → `Application Popup` ID 26 + WER for the next failure; note whether caption is `wsl.exe` or `conhost.exe`. | ~15 min | Determines whether §1 rank-1 (conhost) vs rank-3 (desktop heap) applies. |
| 3 | **Retry-on-infra wrapper** around the hook's `wsl.exe` call (backoff, infra-code allowlist, no mid-handshake kill; cooldown on repeated failure). | ~1–2 h | Converts transient 0xC0000142/E_UNEXPECTED into silent pass instead of deny-under-fail_closed. |
| 4 | **Memory headroom**: system-managed pagefile, trim resident apps; optionally cap WSL `memory=` in `.wslconfig`. | ~30 min + habit | Attacks rank-2 cause; also reduces conhost/desktop-heap contention. |
| 5 | **Desktop heap** (only if #2 shows user32/desktop-heap): raise `SharedSection` 3rd value 512→1024 KB, reboot. | ~15 min + reboot | Fixes the exhaustion case; harmless otherwise but not free (session view space). |
| 6 | **Serialise hook spawns**: ensure Pre/Post hooks never run concurrently (mutex/singleton in wrapper). | ~1 h | Avoids the concurrent-spawn Interop crash documented in codex#46703. |
| 7 | **Move the gate native**: Git Bash + `jq.exe` + `python.exe` + `opa.exe` port of `gate.sh` (path translation `/mnt/c`→`/c`, re-seal `policies.lock`). | ~half day + validation | **Removes the entire failure class**: zero VM crossings, zero wsl.exe per call. This is the structural fix if the problem recurs after #1–#3. |
| 8 | **Alternative structural**: `opa run --server` inside WSL + keepalive; hook calls `curl http://localhost:8181/...`. | ~half day | Same removal of per-call spawns while staying Linux-side; adds a service to supervise. |

## 6. Diagnostics checklist (before changing anything)

1. `Get-WinEvent -FilterHashtable @{LogName='Application'; ProviderName='Application Popup'} -MaxEvents 20` — faulting image name for each 0xC0000142.
2. Correlate failures with `Get-WinEvent -LogName 'Microsoft-Windows-Hyper-V-VmSwitch'` — do failures cluster around switch rebuilds/VM restarts?
3. During a bad patch: `wsl.exe -l -v` (does it hang? → hvsocket wedge signature) and count `Get-Process conhost`.
4. Check commit charge: `Get-Counter '\Memory\Committed Bytes','\Memory\Commit Limit'` near failure time.
5. Note current `.wslconfig` `networkingMode` and whether Docker Desktop "resource saver" is enabled.

## Key sources

- 0xC0000142 mechanics: https://learn.microsoft.com/en-us/archive/blogs/winsdk/what-is-up-with-the-application-failed-to-initialize-properly-0xc0000142-error ; https://learn.microsoft.com/en-us/previous-versions/troubleshoot/windows/win32/user-32-kernel-32-not-initialize ; https://learn.microsoft.com/en-us/archive/blogs/ntdebugging/desktop-heap-overview ; https://learn.microsoft.com/en-us/troubleshoot/windows-server/performance/desktop-heap-limitation-out-of-memory
- wsl.exe 0xC0000142 specifically: https://github.com/microsoft/WSL/issues/6707 ; https://github.com/microsoft/WSL/issues/5448 ; https://github.com/zed-industries/zed/issues/62754
- WSL session-transport wedges: https://github.com/microsoft/WSL/issues/41286 ; https://github.com/microsoft/WSL/issues/40795 ; https://github.com/microsoft/WSL/issues/41592 ; https://github.com/openai/codex/issues/46703 ; https://claudeissues.com/issue/104718
- VmSwitch/idle lifecycle: https://github.com/microsoft/WSL/issues/7178 ; https://github.com/microsoft/WSL/issues/40363 ; https://github.com/microsoft/WSL/discussions/8659 ; https://learn.microsoft.com/en-us/windows/wsl/wsl-config ; https://learn.microsoft.com/en-us/windows/wsl/networking
- Keepalive/persistent-channel patterns: https://guidov.github.io/2024/09/15/wsl2-keep-alive/ ; https://lumadock.com/tutorials/hermes-wsl2-gateway-disconnecting ; https://github.com/gitcommit90/1Helm ; https://github.com/Opendray/opendray/blob/main/scripts/install-windows.ps1
- Native-tool availability: https://github.com/open-policy-agent/opa/releases ; https://github.com/git-for-windows/git/issues/3374 ; https://code.claude.com/docs/en/hooks
