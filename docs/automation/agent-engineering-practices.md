# Agent Engineering Practices

日期：2026-05-20

执行者：Codex

## 定位

本文档把 `mattpocock/skills` 中适合 MTPRO 的工程方法论，收敛成 MTPRO 自己的 Agent engineering practices。

它是流程约束和 review 依据，不是 Linear Project，不是 issue body，不授权执行，不推进 `Todo`，不启动 Symphony，不写业务代码。

## 参考来源

- `https://github.com/mattpocock/skills`
- `https://github.com/mattpocock/skills/blob/main/CONTEXT.md`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnose`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/to-issues`
- `https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture`

## MTPRO 吸收的优点

| skills 项目优点 | MTPRO 落点 |
| --- | --- |
| 小而可组合的 skill | AEP 编号流程、`@000` 到 `@007`、Linear single issue execution |
| Shared language / `CONTEXT.md` | `docs/domain/context.md` |
| 先 grill / 对齐，再拆 issue | Human + `@000 / AIE` 蓝图协作、Human + `@001 / PLN` Project Planning |
| Vertical slice / tracer bullet issue | Linear issue 必须是可独立验证的窄闭环 |
| Feedback loop first | 执行 issue 先识别最快 deterministic feedback loop，再跑 `bash checks/run.sh` |
| TDD / red-green-refactor | 触碰 production behavior 时优先从失败测试或明确 fixture 开始 |
| Diagnose loop | bug / CI / replay mismatch 先复现、最小化、假设、插桩、修复、回归 |
| Architecture deepening | Stage Code Audit 和 Root Docs Refresh Gate 检查模块深度、locality、leverage、术语漂移 |
| Handoff | `symphony-issue-handoff.json`、Stage Audit、latest verification summary、PR evidence |

## 执行规则

### Shared Language First

- Agent 进入 MTPRO 时必须读取 `docs/domain/context.md`。
- Project Planning、Linear issue、PR、Stage Audit 和 public type 注释优先使用 canonical terms。
- 遇到 “order”、“fill”、“account”、“execution” 等模糊词时，先判断它在当前 scope 中是 `paper-only`、`future gated` 还是 `forbidden`。
- 稳定术语进入 `docs/domain/context.md`；一次性 implementation detail 不进入 context。
- 只有 hard to reverse、surprising without context 且存在真实 trade-off 的决定才考虑 ADR。

### Feedback Loop First

默认反馈顺序：

```text
focused fixture / unit test
-> focused module test
-> Dashboard smoke 或 App snapshot
-> bash checks/run.sh
-> GitHub required check: checks
```

规则：

- 不能只跑最终大检查而不理解失败点。
- 自动验证不得依赖真实 Binance 网络、signed endpoint、account endpoint、listenKey、broker 或真实订单。
- `bash checks/run.sh` 仍是最终本地验证入口。
- CI / 本地差异先归类为平台边界、依赖边界或业务回归，再修复。

### TDD / Tracer Bullet

触碰 production behavior 时：

1. 写 deterministic fixture / test 表达目标行为。
2. 让它先暴露当前缺口。
3. 用最小 production change 让测试通过。
4. 测试通过后再整理命名、注释和文档。

Tracer bullet 必须切过一个可验证窄闭环，例如：

```text
strategy signal
-> paper action proposal
-> risk blocker
-> paper-only event
-> replay
-> read model / ViewModel
-> report / dashboard evidence
```

Linear issue 应优先拆成这种 vertical slice，而不是按 `Core / Persistence / App / UI` 横向拆成无法独立验收的大块。

### Diagnose Loop

测试失败、PR check 失败或 replay evidence 不一致时：

1. Reproduce：复现失败，记录命令和关键输出。
2. Minimise：收窄到最小测试、fixture、module 或 platform boundary。
3. Hypothesise：写出最可能原因，不做无证据猜测。
4. Instrument：必要时增加临时日志、断言或更具体的测试。
5. Fix：做最小修复，不扩大 scope。
6. Regression-test：补回归测试，并运行 `bash checks/run.sh`。

禁止在未定位前重写大块代码；禁止把 paper-only failure 修成 live / broker fallback；禁止用真实网络或真实账户作为 required validation。

### Architecture Deepening Review

MTPRO 不追求文件数量越多越好，而追求模块有清晰接口、稳定不变量和足够 leverage。

Stage Code Audit 或 Root Docs Refresh Gate 中如发现以下现象，应记录为 architecture deepening candidate：

- 理解一个概念需要在过多浅模块之间跳转。
- 模块 interface 和 implementation 一样复杂。
- UI、adapter、runtime 或 persistence schema 泄漏到 ViewModel / Read Model。
- paper-only、read-only、append-only 不变量没有在 public type 注释或测试中固定。
- 新术语没有进入 `docs/domain/context.md`，导致 PR / issue / root docs 用词漂移。

评估词：

- `Depth`：小接口背后承载多少稳定行为。
- `Locality`：修改一个概念时，变更是否集中。
- `Leverage`：调用者是否通过接口获得足够能力，而不是重复拼装细节。
- `Deletion test`：删除该模块后，复杂度是消失，还是扩散到多个调用点。

Architecture deepening 不自动授权 refactor。它只能进入 Stage Audit / Root Docs Delta / Next Human Project Planning，再由 Human + `@001 / PLN` 决定是否形成新 Project。

### Handoff Discipline

执行 issue 的交接材料至少包括：

- Linked Linear Issue。
- Scope / Non-goals。
- Validation command summary。
- Boundary evidence。
- Pre-PR Codex Code Review。
- GitHub PR Automation 状态。
- `.codex/*` 和 `graphify-out/*` 未进入 PR。
- 如由 symphony-issue 执行，提供 handoff marker evidence。

Project closure 的交接材料必须落为：

- Stage Code Audit Report。
- Root Docs Refresh Gate closure。
- Current Phase Progress Bar。
- `docs/validation/latest-verification-summary.md` 更新。

## 与 AEP 编号流程的关系

```text
0. New Project Initialization
1. Complete Blueprint Design / Human Project Planning
2. Construction Plan / Linear Draft
3. Linear execution contract
4. Parent Codex project supervision
5. symphony-issue single issue execution
6. GitHub PR Automation
7. Stage Code Audit
8. Root Docs Refresh / Current Phase Progress Bar
9. Next Human Project Planning
```

- `docs/domain/context.md` 支撑 0、1、2、3、7、8。
- Feedback Loop First 支撑 3、5、6。
- TDD / Tracer Bullet 支撑 2、3、5。
- Diagnose Loop 支撑 5、6、7。
- Architecture Deepening Review 支撑 7、8、9。

本文档不改变 Linear 唯一可执行 issue、WIP=1、Parent Codex queue preflight、GitHub PR Automation 和 Stage Code Audit 的既有规则。
