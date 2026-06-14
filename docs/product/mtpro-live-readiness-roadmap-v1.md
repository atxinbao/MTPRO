# MTPRO Live Readiness Roadmap v1

日期：2026-05-27

执行者：Codex

## 1. 文档定位

本文保存 Live Readiness 的路线口径。它是 product / architecture roadmap input，不创建 Project / Issue，不推进 `Todo`，不授权 live runtime、signed endpoint、account endpoint / listenKey、private WebSocket、broker adapter、OMS、real order、Live PRO Console 或 production trading。

## 2. 当前基线

MTPRO 已完成 paper / replay / simulated / Workbench beta / read-model-only readiness / module boundary / L4 command boundary / release evidence。Live Readiness 仍保持 gated / blocked / no-default-production-trading。

## 3. Live Readiness Route

| Slice | 状态 | 当前语义 |
| --- | --- | --- |
| L3.0 Live Read-only Readiness Boundary | Done | terminology、credential / endpoint taxonomy、adapter capability matrix、read-model-only boundary |
| L3.1 Account / Position / Balance Read-model-only | Done | account / position / balance 只作为 read-model-only evidence，不是真实账户 runtime |
| L3.2 Private Stream / Account Snapshot Simulation Gate | Done | local fixture / simulated source identity，不接 private stream |
| L3.3 Live Monitoring Read-only Console v2 | Done | monitoring source / health / connection readiness explanation，只读展示 |
| L3.4 Strategy / Trader Instance Readiness | Done | strategy / trader lifecycle 和 identity boundary |
| Engine Boundary / Target Layout / Trader Layout / Target Graph | Done | module structure before L4 |
| L4 Live Production / Trading Commands v1 | Done | L4 Live Production / Trading Commands v1 complete with no-default-production-trading policy |
| Production Cutover Readiness Gate | Done | readiness-only / no-real-broker-authorization |

## 4. 与 Workbench 的关系

Workbench / Dashboard 可以展示 blocked gates、readiness evidence、freshness、stale / missing / blocked reason、Report / Events links；不得显示 trading button、live command、order form、secret input default path 或 broker connect CTA。

## 5. 验证要求

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- forbidden capability guards for endpoint / broker / command / production trading

## 6. 后续推进规则

任何 Live / production 相关执行都必须由 Human + `@001 / PLN` 新建独立 Project / Issue contract，并由 Parent Codex WIP=1 queue preflight 选择唯一 eligible issue。本文不授权自动推进。
