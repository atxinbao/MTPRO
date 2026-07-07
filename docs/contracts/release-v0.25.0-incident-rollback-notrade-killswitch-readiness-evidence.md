# MTPRO v0.25.0 Incident Rollback / No-trade / Kill-switch Readiness Evidence

Date: 2026-07-07  
Author: Codex

## Scope

This document records `V0250-006` incident rollback, no-trade state and kill-switch readiness evidence for the Binance Spot + Binance USDⓈ-M Futures production-readiness track.

The scope is readiness vocabulary and blocked evidence only. It does not implement emergency stop command, shutdown runtime, restore runtime, broker connection, live command UI or production cutover.

## Validation Anchors

- `GH-1377-VERIFY-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE`
- `TVM-RELEASE-V0250-INCIDENT-ROLLBACK-NOTRADE-KILLSWITCH-READINESS-EVIDENCE`
- `V0250-006-INCIDENT-ROLLBACK-READINESS`
- `V0250-006-NO-TRADE-STATE-EVIDENCE`
- `V0250-006-KILL-SWITCH-READINESS`
- `V0250-006-BLOCKED-OPERATIONAL-CONTROL`
- `V0250-006-NO-EMERGENCY-STOP-RUNTIME`
- `V0250-006-NO-LIVE-COMMAND-UI`

## Product Coverage

- `spot` readiness evidence must remain blocked from operational control runtime.
- `usdsPerpetual` readiness evidence must remain blocked from operational control runtime.

Both products must keep incident rollback, no-trade and kill-switch evidence as readiness-only material until a separately authorized runtime project implements operational controls.

## Explicit Non-goals

- No emergency stop command.
- No shutdown runtime.
- No restore runtime.
- No broker connection.
- No live command UI.
- No production cutover.
