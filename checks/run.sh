#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_command() {
  local command_name="$1"
  local setup_hint="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "MTPRO setup hint: missing required command '$command_name'."
    echo "$setup_hint"
    exit 1
  fi
}

require_sqlite_pkg_config() {
  require_command "pkg-config" "Install pkg-config before running SwiftPM checks. On Ubuntu: sudo apt-get install -y pkg-config libsqlite3-dev. On macOS with Homebrew: brew install pkg-config sqlite."

  if ! pkg-config --exists sqlite3; then
    echo "MTPRO setup hint: sqlite3 pkg-config metadata is unavailable."
    echo "Install sqlite development headers before running SwiftPM checks. On Ubuntu: sudo apt-get install -y libsqlite3-dev. On macOS with Homebrew: brew install sqlite pkg-config."
    exit 1
  fi
}

require_swift_toolchain() {
  require_command "swift" "Install Swift 6.3.x or newer before running checks/run.sh. GitHub Actions pins ubuntu-24.04 and verifies the runner Swift 6.3.x toolchain."
}

require_swift_toolchain
require_sqlite_pkg_config

git diff --check
bash checks/automation-readiness.sh
if [[ "$(uname -s)" == "Darwin" ]]; then
  swift build --product Dashboard
  DASHBOARD_SMOKE=1 swift run Dashboard
else
  echo "Skipping Dashboard build and smoke run: SwiftUI shell is macOS-only."
fi
swift test

echo "MTPRO checks passed."
