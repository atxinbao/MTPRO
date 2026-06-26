# Release v0.17.0 Signed Status Query Retry / Timeout / Classified Failure Model Contract

日期：2026-06-27

执行者：Codex

本文档服务 GitHub fallback issue `#1141 / GH-1141 Add signed status query retry / timeout / classified failure model`。

GH-1141 在 GH-1139 定义的 `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 边界内执行，并依赖 GH-1140 已完成的 artifact bundle replay validator。GH-1141 只在 Binance Spot Testnet signed order status query path 外层增加 retry / timeout / classified failure model，把单次 status query transport 调用收敛成有上限、可脱敏审计、失败即关闭的 evidence。它不读取 credential value，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order，不创建 tag / GitHub Release，不授权 production cutover。

## V0170-003-BOUNDED-STATUS-QUERY-RETRY

`V0170-003-BOUNDED-STATUS-QUERY-RETRY`

Status query wrapper 必须由调用方显式提供 `maxAttempts`，默认策略固定为有限次数 retry。允许 retry 的失败类型只包括：

- timeout
- HTTP 408 / 429 / 5xx
- transport failure

HTTP 4xx 中除 408 / 429 外均为 non-retryable failure，必须停止并输出 fail-closed result。

## V0170-003-PER-ATTEMPT-TIMEOUT

`V0170-003-PER-ATTEMPT-TIMEOUT`

每次 status query attempt 必须有独立 timeout。timeout 触发后必须记录 attempt number、分类 reason、retryScheduled 和脱敏 detail。timeout 不能转换成成功，也不能隐藏为 unknown failure。

## V0170-003-CLASSIFIED-FAILURE-EVIDENCE

`V0170-003-CLASSIFIED-FAILURE-EVIDENCE`

每个失败 attempt 必须分类为确定枚举，包括 timeout、retryable HTTP status、non-retryable HTTP status、transport failure、retry limit exceeded、boundary drift 或 redaction policy violation。分类 evidence 只允许保存脱敏 detail，不允许保存 API header、secret、signature、raw request、raw response 或 production host marker。

## V0170-003-RETRY-LIMIT-FAIL-CLOSED

`V0170-003-RETRY-LIMIT-FAIL-CLOSED`

当 retryable failure 耗尽 `maxAttempts` 后，最终 result 必须 fail closed，并把最后一个 attempt 的 failure 分类提升为 retry limit exceeded。wrapper 不允许继续触达 transport，不允许打开 production fallback，不允许返回未分类成功。

## V0170-003-REDACTED-FAILURE-EVIDENCE

`V0170-003-REDACTED-FAILURE-EVIDENCE`

Failure detail 必须通过 release v0.16.1 shared redaction policy。若 detail 自身包含禁止 marker，wrapper 必须替换为固定脱敏提示，而不是持久化原始内容。

允许证据：

- run / request / transport result 的 deterministic id
- attempt number
- failure reason
- retryScheduled
- redacted failure detail
- retry policy value

禁止证据：

- credential value
- API header value
- secret value
- listenKey
- signature value
- raw request payload
- raw response payload
- production endpoint marker
- raw broker payload
- raw order payload

## V0170-003-NO-PRODUCTION-CUTOVER

`V0170-003-NO-PRODUCTION-CUTOVER`

GH-1141 keeps these flags closed：

- `productionTradingEnabledByDefault=false`
- `productionSecretReadEnabled=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionOrderSubmitCancelReplaceEnabled=false`
- `productionCutoverAuthorized=false`

GH-1141 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不打开 Dashboard trading button、order form、Live PRO Console command 或 production OMS。

## TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL

`TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`

Validation anchors：

- `GH-1141-VERIFY-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`
- `TVM-RELEASE-V0170-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL`
- `V0170-003-BOUNDED-STATUS-QUERY-RETRY`
- `V0170-003-PER-ATTEMPT-TIMEOUT`
- `V0170-003-CLASSIFIED-FAILURE-EVIDENCE`
- `V0170-003-RETRY-LIMIT-FAIL-CLOSED`
- `V0170-003-REDACTED-FAILURE-EVIDENCE`
- `V0170-003-NO-PRODUCTION-CUTOVER`

Required validation：

- `swift test --filter TargetGraphTests/testGH1141ReleaseV0170SignedStatusQueryRetryTimeoutFailureModel`
- `bash checks/verify-v0.17.0-signed-status-query-retry-timeout-failure-model.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
