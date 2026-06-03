@_exported import Workbench

/// `App` target 是 MTP-221 后保留的兼容导出壳。
///
/// Workbench / Dashboard 的真实 read-model-only consumption source 已由 `Workbench`
/// target 编译；`App` 只作为 compatibility export 维持既有测试和外部 import surface，
/// 不拥有 Runtime、Adapter、persistence schema、account payload、broker state 或 live command surface。
