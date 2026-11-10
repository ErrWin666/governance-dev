# k-003 — Verification, skepticism & attack tooling (L4)

Date: 2026-11-10 | Source: background research agent (web + GitHub)

## Canonical artifacts
- **SARIF 2.1.0** (OASIS) — findings interchange; semgrep/codeql emit it, GitHub renders it
- **`verdict.json`** — converging schema `{verdict|decision, findings[], feedback}` + exit codes: closedloop, acig, SathiaAI/adversarial-review (best-in-class: verdict computed from recorded artifacts only, tamper-evident digest), hyperfixer
- **Evidence bundles** — assay signed packs (SHA-256+Ed25519), CI-recomputed fields agent could falsify (developertoolkit.ai/evidence-bundle)

## Verifier (citation checking must be NON-LLM, fail-closed)
- Magneto (northwood-labs/magneto) — MCP citation gate, exact-match file:line validation
- claimcheck (ctaio-claimcheck) — per-claim JSON verdicts (TRUE/UNVERIFIABLE/OVERCLAIM) + non-zero exit → CI gate
- GroundCheck — hook re-checks Read(path:line) citations vs filesystem
- PR-Agent (qodo-ai/pr-agent) — mature, `--json-output review.json`

## Skeptic (adversarial pipelines)
- bug-hunter — Hunter→Skeptic→Referee; verdicts only from Referee
- adverse (addyosmani/adverse) — multi-persona + cross-review; findings tagged consensus/disputed
- adversarial-review skills — `.reviews/` artifacts, 4-state verdicts

## Attacker
- Semgrep + p/security-audit, p/owasp-top-ten — `--json`/`--sarif` output
- ClusterFuzzLite — PR-scoped fuzzing → executable crash proof
- Buttercup (trailofbits, AIxCC finalist) — **PoVs = strongest bug-proof format**
- garak package-hallucination probe — catches invented dependencies

## Clever-Hans answer
Mutation testing = only mechanical proof "code wrong, tests didn't notice" — already ours in A5 (mutmut). Survived mutant = file:line of the hole.

## Trust hierarchy
executable proof (crash/PoV/mutant) > deterministic check (semgrep, citation match) > LLM judgment (cross-validated only)
