# GitHub Workflows

Updated: 2026-07-24
Maintainer: Codex

## Current workflows

| File | Purpose |
| --- | --- |
| `checks.yml` | Required PR fast lane and the Linux/macOS release validation matrix. Repository contents are read-only by default; only `release-publication-checks` receives `contents: write`. |
| `release-v0.33.0-demo-canary-validation.yml` | Manual Binance Demo Network Spot or USD-M Futures canary validation on the dedicated self-hosted runner and `binance-demo` environment. |

## Historical validation contracts

The following manual workflows were removed from the active GitHub Actions
surface and retained under `docs/history/workflows/`:

- `docs/history/workflows/release-v0.16.0-manual-testnet-validation.yml`
- `docs/history/workflows/release-v0.17.0-manual-artifact-validation.yml`

They are immutable historical evidence, not executable GitHub workflows and not
the current Demo canary operator entry. Their source contracts, focused
verifiers, tests, runbooks, and current indexes now resolve to the archive path.

## Maintenance rules

- Keep workflow-level permissions at `contents: read`.
- Grant write permission only to the job that performs the write operation.
- Set `persist-credentials: false` on every checkout.
- Give every job a bounded timeout.
- Keep pull-request jobs free of repository secrets and release credentials.
- Preserve the full Linux/macOS matrix before release publication.
