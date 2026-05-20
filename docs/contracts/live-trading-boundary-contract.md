# Live Trading Boundary Contract

日期：2026-05-21

执行者：Codex

本文档定义 `MTPRO Live Trading Boundary Definition v1` 的 Live trading foundation 边界合同。它只固定 taxonomy、gate 顺序、当前禁止能力和后续 issue 的验证入口，不实现任何 API key、secret 存储、signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS 或 `LiveExecutionAdapter`。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不启动真实交易，不读取 secret。

## MTP-61 Live trading foundation capability taxonomy 和 gate

`MTP-61-LIVE-FOUNDATION-TAXONOMY`

Live trading foundation 在当前 Project 中不是可执行实盘交易能力，而是一组必须先被命名、隔离和验证的受门禁能力。MTP-61 只允许定义这些词汇和 gate，不允许把它们变成可调用接口。

| Taxonomy term | 中文定义 | 当前状态 | 当前允许输出 | 当前禁止输出 |
| --- | --- | --- | --- | --- |
| `live capability` | 未来实盘交易基础能力的候选名称，例如 secret policy、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle。 | Future / gated | 合同术语、gate 列表、blocked evidence 锚点 | 可执行 API、Swift live adapter、真实订单命令 |
| `blocked capability` | 当前已识别但明确被阻断的能力；它可以被展示为 blocked evidence，但不能被执行。 | Blocked / non-executable | docs anchor、validation matrix anchor、后续 read-model-only evidence 输入 | fallback 到 paper order、broker action、signed endpoint |
| `future gate` | 允许某项 live capability 进入后续 Project Definition 前必须满足的条件。 | Required before future scope | gate 名称、证据要求、non-goal 边界 | 自动解锁后续 issue、自动推进 Todo |
| `forbidden capability` | 当前 Project 明确禁止的能力；任何实现、测试夹具或文档不得把它表达成当前可用能力。 | Forbidden in current scope | 禁止项清单、mechanical validation anchor | API key、secret、signed endpoint、account endpoint、listenKey、broker、real order、OMS、LiveExecutionAdapter |

## MTP-61 gate sequence

`MTP-61-LIVE-GATE-SEQUENCE`

Live trading foundation 必须按门禁顺序推进。当前 issue 只完成 Gate 0 的命名和验证锚点；后续 gate 只有在对应 Linear issue 成为唯一 configured executable issue 后才能施工。

| Gate | 名称 | 目标 | 允许证据 | 禁止扩展 |
| --- | --- | --- | --- | --- |
| Gate 0 | Taxonomy / blocked boundary | 定义 live capability、blocked capability、future gate、forbidden capability。 | `docs/contracts/live-trading-boundary-contract.md`、`TVM-LIVE-TRADING-FOUNDATION`、automation readiness anchor | 任何 Live implementation |
| Gate 1 | API key / signed / account / listenKey boundary | 定义 secret、signed endpoint、account endpoint 和 listenKey 的禁止边界。 | 后续 MTP-62 contract / validation anchor | secret 存储、API key 读取、signed request |
| Gate 2 | Adapter capability isolation | 隔离 current public read-only adapter 与 future live adapter capability。 | 后续 MTP-63 adapter isolation contract | `LiveExecutionAdapter`、broker adapter、exchange execution adapter |
| Gate 3 | Real order lifecycle terms | 定义 real order lifecycle 术语、future gate 和 forbidden capability tests。 | 后续 MTP-64 terminology / tests anchor | submit / cancel / replace、real order state machine |
| Gate 4 | Live readiness blocked read model | 新增最小 `LiveReadiness` / `LiveBlockedEvidence` read-model-only 表达。 | 后续 MTP-65 read model / tests | command surface、execution authorization |
| Gate 5 | Workbench blocked evidence surface | 将 blocked evidence 接入 Dashboard / Report / Event Timeline read-model-only 展示。 | 后续 MTP-66 App / Dashboard evidence | live button、risk control command、position management command |
| Gate 6 | Stage validation closeout | 收口 validation matrix、automation readiness 和 stage audit input material。 | 后续 MTP-67 stage audit input | 最终 Stage Code Audit Report、Root Docs Refresh Gate |

## MTP-61 slice separation

`MTP-61-LIVE-SLICE-SEPARATION`

MTP-61 只定义 Live trading foundation 的 taxonomy 和 gate，不施工后续实盘产品切片。以下切片必须继续保持 Future / gated：

| Slice | 本 Project 内的位置 | MTP-61 边界 |
| --- | --- | --- |
| 实盘交易基础边界 / Live trading foundation | 当前 Project 的唯一范围 | 只定义 capability taxonomy、gate、blocked boundary 和 validation anchor。 |
| 实盘监控台 / Live monitoring console | Future slice | 不定义 live runtime health 实现，不接连接状态、行情流、订单流、错误、延迟监控。 |
| 实盘执行控制 / Live execution control | Future slice | 不定义 submit / cancel / replace 控制，不处理 execution report、reconciliation 或 incident fallback。 |
| 实盘风险控制 / Live risk control | Future slice | 不实现真实 pre-trade risk、仓位限制、订单金额限制、频率限制、熔断或禁交易状态。 |
| 实盘审计 / 事故回放 / 停机控制 | Future slice | 不实现 live audit trail、incident replay、emergency stop、shutdown / restore policy。 |

## Current allowed evidence

MTP-61 当前只允许产生以下 evidence：

- Live trading foundation taxonomy。
- Gate sequence。
- 当前禁止能力清单。
- Validation matrix anchor。
- Automation readiness anchor。
- PR evidence 和 `bash checks/run.sh` 摘要。

这些 evidence 是 non-executable blocked evidence，不代表实盘 readiness 已满足，不代表后续 issue 可自动进入 `Todo`。

## Forbidden capabilities

以下能力在 MTP-61 中必须保持禁止：

- API key。
- secret storage。
- signed endpoint。
- account endpoint。
- listenKey user data stream。
- broker / exchange execution adapter。
- real order submit / cancel / replace。
- real order lifecycle implementation。
- OMS。
- `LiveExecutionAdapter`。
- live monitoring console。
- live execution control。
- live risk control。
- live audit / incident replay / stop controls。
- live order button、risk control command、position management command。

## Validation contract

MTP-61 必须满足：

- `bash checks/run.sh` 通过。
- `checks/automation-readiness.sh` 必须检查本文档和 `TVM-LIVE-TRADING-FOUNDATION` 锚点。
- `docs/validation/trading-validation-matrix.md` 必须能定位 Live trading foundation taxonomy 和 gate。
- `docs/validation/validation-plan.md` 必须说明 MTP-61 只做 taxonomy / gate / contract / blocked evidence。
- PR evidence 必须确认没有 API key、secret storage、signed endpoint、account endpoint、listenKey、broker、real order、OMS 或 `LiveExecutionAdapter` 实现。
