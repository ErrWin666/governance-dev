# K-006 — SonarQube + scanner-class MCP research (2026-11)

Source: background research agent #2, primary sources. Complements K-005.

## Headline

SonarSource ships an OFFICIAL `sonarqube-mcp-server` (584★, SSAL
source-available). Java, Docker `sonarsource/sonarqube-mcp` or JAR (JDK 21+),
stdio + Streamable HTTP. Toolsets: analysis, issues, projects,
quality-gates, rules, duplications, measures, security-hotspots,
dependency-risks, coverage.

## Hard requirements (governance-relevant)

- **Version floor: SonarQube Server 2025.1+ / Community Build 25.1+** —
  older instances (9.x/10.x incl. 9.9 LTS) are refused at startup. Check
  `GET /api/server/version` FIRST.
- USER-type token only (project/global tokens rejected).
- `SONARQUBE_URL` must be set for self-hosted — defaults to Cloud otherwise.
- `TELEMETRY_DISABLED=true` — on by default.
- Server-hosted MCP mode (SonarQube itself serves MCP over HTTP) needs
  Server 2026.3+; otherwise run the standalone container/JAR.
- `change_sonar_issue_status` is a WRITE tool — exclude from read-only
  role allowlists.
- SSAL license: internal non-competing agent use is permitted; it is not
  an OSI license — note in vendor ledger.

## Web API fallback (works on ANY version)

```
GET /api/qualitygates/project_status?projectKey=X   (deprecated on newest;
        use api/measures/component?metricKeys=quality_gate_details)
GET /api/issues/search?componentKeys=X&issueStatuses=OPEN
GET /api/hotspots/search?projectKey=X
GET /api/server/version
```

3 curl calls ≈ 80% of the MCP's read value with zero new infrastructure —
fits the minimal-surface posture. `analyze_code_snippet` (MCP-only) is the
differentiator for implementer pre-commit checks.

## Scanner-class conclusions

- **trivy-mcp** (`aquasecurity/trivy-mcp`, 56★, MIT, official plugin):
  adopt alongside — `trivy plugin install mcp`.
- **ZAP MCP** (`dtkmn/mcp-zap-server`, 68★): only if DAST targets exist.
- **Dependency-Track**: no official MCP (OWASP DT #5791 wants designed
  agent APIs, not REST wrappers). Community pilots only if DT deployed.
- **gitleaks / Nuclei / Bearer / Checkmarx / Veracode**: skip dedicated
  MCP — CLI-first tools; wrappers add process risk for no gain.
- **Aggregator suites** (mcp-security-hub, sast-mcp-server): use as
  reference, not dependency — unvetted multi-tool surface.

## Role assignments

| Role | SonarQube tools |
|---|---|
| verifier | quality-gates, measures, coverage, duplications |
| skeptic | issues, hotspots, measures (challenge claims) |
| attacker | security-hotspots, dependency-risks |
| implementer | analyze_code_snippet (pre-commit self-check) |
| supervisor | gate pass/fail as merge condition |
