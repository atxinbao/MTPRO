#!/usr/bin/env bash
set -euo pipefail

# GH-992-VERIFY-V0121-JSON-INSPECTION-GUARDS
# V0121-005-READINESS-JSON-INSPECTION
# V0121-005-GENERATED-EVIDENCE-PROVENANCE
# V0121-005-PLACEHOLDER-AND-PRODUCTION-FLAG-REJECTION
# TVM-RELEASE-V0121-JSON-INSPECTION-GUARD

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.12.1 JSON inspection guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

require_text_contains() {
  local text="$1"
  local expected="$2"

  grep -Fq "$expected" <<<"$text" || fail "output must contain: $expected"
}

TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/validation/latest-verification-summary.md"
VALID_COMMIT="22fb2aff1fe706b9bfc32f3ecb2a1aa11228aa24"

for anchor in \
  "GH-992-VERIFY-V0121-JSON-INSPECTION-GUARDS" \
  "V0121-005-READINESS-JSON-INSPECTION" \
  "V0121-005-GENERATED-EVIDENCE-PROVENANCE" \
  "V0121-005-PLACEHOLDER-AND-PRODUCTION-FLAG-REJECTION" \
  "TVM-RELEASE-V0121-JSON-INSPECTION-GUARD"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

require_file_contains "checks/verify-v0.12.0.sh" "bash checks/verify-v0.12.1-json-inspection-guards.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.12.1-json-inspection-guards.sh"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.12.1-json-inspection-guards.sh"
require_file_contains "$READINESS" "Release v0.12.1 JSON inspection guard anchor"
require_file_contains "$LATEST" "v0.12.1 JSON inspection guard"
require_file_contains "$TESTS" "testGH992ReadinessJSONInspectionGuardsValidateGeneratedEvidence"

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/mtpro-gh992-json-inspection.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

baseline_id="gh-992-baseline"
followup_id="gh-992-followup"
export_output="$tmp_root/export.out"
compare_output="$tmp_root/compare.out"

MTPRO_READINESS_ROOT="$tmp_root" swift run mtpro readiness create "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" swift run mtpro readiness create "$followup_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness build "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness build "$followup_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness validate "$baseline_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness validate "$followup_id" >/dev/null
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness export "$baseline_id" >"$export_output"
MTPRO_READINESS_ROOT="$tmp_root" MTPRO_READINESS_SOURCE_COMMIT="$VALID_COMMIT" swift run mtpro readiness compare "$baseline_id" "$followup_id" >"$compare_output"

require_text_contains "$(cat "$export_output")" "exportSnapshotOnly=true"
require_text_contains "$(cat "$export_output")" "redactedEvidenceOnly=true"
require_text_contains "$(cat "$compare_output")" "comparedSections=policy,artifacts,risk-limits,kill-switch-state,approval-state,source-run-evidence"
require_text_contains "$(cat "$compare_output")" "compareDoesNotMutateAssessments=true"

python3 - "$tmp_root" "$baseline_id" "$followup_id" "$VALID_COMMIT" "$export_output" "$compare_output" <<'PY'
import copy
import hashlib
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
baseline_id = sys.argv[2]
followup_id = sys.argv[3]
valid_commit = sys.argv[4]
export_output_path = Path(sys.argv[5])
compare_output_path = Path(sys.argv[6])

sha_re = re.compile(r"^sha256:[0-9a-f]{64}$")
source_run_re = re.compile(r"^source-run-[0-9a-f]{16}$")
commit_re = re.compile(r"^[0-9a-f]{40}$")
placeholder_commits = {
    "0000000000000000000000000000000000000000",
    "0123456789abcdef0123456789abcdef01234567",
    "1111111111111111111111111111111111111111",
}
placeholder_source_runs = {"gh-963-source-run"}
forbidden_true_flags = {
    "productionTradingEnabledByDefault",
    "productionCutoverAuthorized",
    "productionSecretRead",
    "productionEndpointConnected",
    "brokerEndpointConnected",
    "productionBrokerConnected",
    "productionOrderSubmitted",
    "realOrderSubmissionEnabled",
    "testnetOrderSubmissionAllowed",
    "testnetOrderRoutingAllowed",
}
forbidden_literals = [
    "0123456789abcdef0123456789abcdef01234567",
    "gh-963-source-run",
    "productionTradingEnabledByDefault=true",
    "productionCutoverAuthorized=true",
    "productionSecretRead=true",
    "productionEndpointConnected=true",
    "brokerEndpointConnected=true",
    "productionOrderSubmitted=true",
    "testnetOrderSubmissionAllowed=true",
    "testnetOrderRoutingAllowed=true",
]


def load_json(path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def read_bytes(path):
    with path.open("rb") as handle:
        return handle.read()


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def require_sha(value, name):
    require(isinstance(value, str) and sha_re.match(value), f"{name} must be sha256:<64 hex>")


def check_false_flags(value, path="root"):
    if isinstance(value, dict):
        for key, nested in value.items():
            if key in forbidden_true_flags:
                require(nested is False, f"{path}.{key} must stay false")
            check_false_flags(nested, f"{path}.{key}")
    elif isinstance(value, list):
        for index, nested in enumerate(value):
            check_false_flags(nested, f"{path}[{index}]")


def parse_key_value_output(path):
    parsed = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            parsed[key] = value
    return parsed


def snapshot_for(assessment_id):
    assessment_root = root / "assessments" / assessment_id
    registry = load_json(root / "registry.json")
    manifest = load_json(assessment_root / "manifest-v2.json")
    artifact_path = assessment_root / "artifacts" / "readiness-summary.json"
    artifact_bytes = read_bytes(artifact_path)
    artifact = json.loads(artifact_bytes.decode("utf-8"))
    generation_id = manifest["generationID"]
    generation_root = assessment_root / "generations" / generation_id
    bundle_path = generation_root / "readiness-bundle-v2.json"
    bundle_manifest_path = generation_root / "readiness-bundle-v2.manifest.json"
    bundle_bytes = read_bytes(bundle_path)
    bundle = json.loads(bundle_bytes.decode("utf-8"))
    bundle_manifest = load_json(bundle_manifest_path)
    return {
        "registry": registry,
        "manifest": manifest,
        "artifact": artifact,
        "artifact_bytes": artifact_bytes,
        "bundle": bundle,
        "bundle_bytes": bundle_bytes,
        "bundle_manifest": bundle_manifest,
        "export_output": parse_key_value_output(export_output_path),
        "compare_output": parse_key_value_output(compare_output_path),
    }


def validate_snapshot(snapshot, assessment_id):
    registry = snapshot["registry"]
    manifest = snapshot["manifest"]
    artifact = snapshot["artifact"]
    artifact_bytes = snapshot["artifact_bytes"]
    bundle = snapshot["bundle"]
    bundle_bytes = snapshot["bundle_bytes"]
    bundle_manifest = snapshot["bundle_manifest"]
    export_output = snapshot["export_output"]
    compare_output = snapshot["compare_output"]

    for document_name, document in [
        ("registry", registry),
        ("manifest", manifest),
        ("artifact", artifact),
        ("bundle", bundle),
        ("bundleManifest", bundle_manifest),
    ]:
        check_false_flags(document, document_name)

    require(registry["schemaVersion"] == "v0.12.0.readiness-assessment-registry.v1", "registry schema mismatch")
    require(registry["registryPath"] == ".local/mtpro/readiness/registry.json", "registry path mismatch")
    require_sha(registry["registryChecksum"], "registry.registryChecksum")
    entry = next((item for item in registry["entries"] if item["assessmentID"] == assessment_id), None)
    require(entry is not None, f"registry must contain {assessment_id}")
    require_sha(entry["entryChecksum"], "registry entry checksum")
    require(entry["artifactPaths"]["assessmentDirectoryPath"].endswith(assessment_id), "registry artifact path mismatch")

    require(manifest["assessmentID"] == assessment_id, "manifest assessmentID mismatch")
    require(manifest["schemaVersion"] == "v0.12.0.readiness-assessment-manifest.v2", "manifest schema mismatch")
    require(manifest["canonicalizationAlgorithm"] == "canonical-json-sha256", "manifest canonicalization mismatch")
    require(manifest["artifactContentType"] == "application/json", "manifest artifact content type mismatch")
    require(commit_re.match(manifest["sourceCommit"]) and manifest["sourceCommit"] == valid_commit, "manifest sourceCommit must be the real accepted commit")
    require(manifest["sourceCommit"] not in placeholder_commits, "manifest sourceCommit must not be placeholder")
    require_sha(manifest["artifactSHA256"], "manifest.artifactSHA256")
    require("manifestChecksum" in manifest, "manifest manifestChecksum must be present")
    require_sha(manifest["manifestChecksum"], "manifest.manifestChecksum")
    require(isinstance(manifest["artifactBytes"], int) and manifest["artifactBytes"] > 0, "manifest artifactBytes must be positive")
    require(manifest["artifactBytes"] != 512, "manifest artifactBytes must not be fixed 512")

    actual_artifact_sha = "sha256:" + hashlib.sha256(artifact_bytes).hexdigest()
    require(manifest["artifactSHA256"] == actual_artifact_sha, "manifest artifactSHA256 must match artifact bytes")
    require(manifest["artifactBytes"] == len(artifact_bytes), "manifest artifactBytes must match artifact bytes")
    expected_source_run = "source-run-" + actual_artifact_sha.removeprefix("sha256:")[:16]
    require(manifest["sourceRunIDs"] == [expected_source_run], "manifest sourceRunIDs must derive from artifact sha")
    require(source_run_re.match(expected_source_run), "derived sourceRunID shape mismatch")
    require(expected_source_run not in placeholder_source_runs, "sourceRunID must not be placeholder")

    require(artifact["assessmentID"] == assessment_id, "artifact assessmentID mismatch")
    require(artifact["generationID"] == manifest["generationID"], "artifact generationID mismatch")
    require(artifact["sourceCommit"] == manifest["sourceCommit"], "artifact sourceCommit mismatch")
    require(artifact["artifactPath"].endswith(f"{assessment_id}/artifacts/readiness-summary.json"), "artifact path mismatch")
    require(artifact["redactedEvidenceOnly"] is True, "artifact must be redacted evidence only")
    require(artifact["noSecretValue"] is True, "artifact must state no secret value")
    require(artifact["noOrderPayload"] is True, "artifact must state no order payload")
    require_sha(artifact["sourceRunManifestChecksum"], "artifact.sourceRunManifestChecksum")
    require_sha(artifact["portfolioProjectionChecksum"], "artifact.portfolioProjectionChecksum")
    require_sha(artifact["reconciliationChecksum"], "artifact.reconciliationChecksum")
    require(artifact["eventIDs"], "artifact eventIDs must be present")
    require(artifact["riskDecisionIDs"], "artifact riskDecisionIDs must be present")
    require(artifact["omsDryRunLifecycleIDs"], "artifact oms lifecycle IDs must be present")

    require(bundle["assessmentID"] == assessment_id, "bundle assessmentID mismatch")
    require(bundle["generationID"] == manifest["generationID"], "bundle generationID mismatch")
    require(bundle["sourceCommit"] == manifest["sourceCommit"], "bundle sourceCommit mismatch")
    require(bundle["sourceRunIDs"] == manifest["sourceRunIDs"], "bundle sourceRunIDs mismatch")
    require(bundle["reviewState"] == "in-review", "bundle reviewState mismatch")
    require(bundle["immutableAfterReview"] is True, "bundle immutableAfterReview must be true")
    require(bundle["changeRequiresNewGeneration"] is True, "bundle changeRequiresNewGeneration must be true")
    require("bundleChecksum" in bundle, "bundle bundleChecksum must be present")
    require_sha(bundle["bundleChecksum"], "bundle.bundleChecksum")
    require(bundle["artifactSnapshots"], "bundle artifactSnapshots must be present")
    snapshot = bundle["artifactSnapshots"][0]
    require(snapshot["manifestChecksum"] == manifest["manifestChecksum"], "bundle snapshot manifest checksum mismatch")
    require(snapshot["artifactSHA256"] == manifest["artifactSHA256"], "bundle snapshot artifact sha mismatch")
    require(snapshot["artifactPath"] == artifact["artifactPath"], "bundle snapshot artifact path mismatch")
    require_sha(snapshot["contentValidationChecksum"], "bundle snapshot content validation checksum")

    actual_bundle_sha = "sha256:" + hashlib.sha256(bundle_bytes).hexdigest()
    require(bundle_manifest["assessmentID"] == assessment_id, "bundle manifest assessmentID mismatch")
    require(bundle_manifest["generationID"] == manifest["generationID"], "bundle manifest generationID mismatch")
    require("bundleChecksum" in bundle_manifest, "bundle manifest bundleChecksum must be present")
    require(bundle_manifest["bundleChecksum"] == bundle["bundleChecksum"], "bundle manifest checksum mismatch")
    require(bundle_manifest["bundleJSONSHA256"] == actual_bundle_sha, "bundle manifest JSON sha mismatch")
    require(bundle_manifest["bundleBytes"] == len(bundle_bytes), "bundle manifest bundleBytes mismatch")
    require(bundle_manifest["bundleBytes"] != 512, "bundle manifest bundleBytes must not be fixed 512")
    require_sha(bundle_manifest["manifestChecksum"], "bundle manifest manifestChecksum")

    for output_name, parsed in [("export", export_output), ("compare", compare_output)]:
        require(parsed.get("productionTradingEnabledByDefault") == "false", f"{output_name} production trading flag")
        require(parsed.get("productionSecretRead") == "false", f"{output_name} production secret flag")
        require(parsed.get("productionEndpointConnected") == "false", f"{output_name} production endpoint flag")
        require(parsed.get("brokerEndpointConnected") == "false", f"{output_name} broker endpoint flag")
        require(parsed.get("productionOrderSubmitted") == "false", f"{output_name} production order flag")
        require(parsed.get("testnetOrderSubmissionAllowed") == "false", f"{output_name} testnet submit flag")
        require(parsed.get("testnetOrderRoutingAllowed") == "false", f"{output_name} testnet routing flag")
        require(parsed.get("productionCutoverAuthorized") == "false", f"{output_name} cutover flag")
        require(parsed.get("boundaryHeld") == "true", f"{output_name} boundary flag")

    require(export_output.get("exportSnapshotOnly") == "true", "export must remain snapshot-only")
    require(export_output.get("redactedEvidenceOnly") == "true", "export must remain redacted")
    require(export_output.get("noSecretValue") == "true", "export must not expose secret values")
    require(export_output.get("noOrderPayload") == "true", "export must not expose order payloads")
    require("source-run-evidence" in compare_output.get("comparedSections", ""), "compare must include source-run evidence")
    require_sha(compare_output.get("reportChecksum", ""), "compare.reportChecksum")
    require(compare_output.get("compareDoesNotMutateAssessments") == "true", "compare must be non-mutating")
    require(compare_output.get("operatorReviewOnly") == "true", "compare must remain operator-review-only")


snapshot = snapshot_for(baseline_id)
validate_snapshot(snapshot, baseline_id)

all_generated_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted(root.rglob("*"))
    if path.is_file() and path.suffix in {".json", ".out"}
)
for forbidden in forbidden_literals:
    require(forbidden not in all_generated_text, f"generated evidence must not contain {forbidden}")


def expect_failure(name, mutator):
    tampered = copy.deepcopy(snapshot)
    mutator(tampered)
    try:
        validate_snapshot(tampered, baseline_id)
    except AssertionError:
        return
    raise AssertionError(f"tampered evidence unexpectedly passed: {name}")


expect_failure(
    "placeholder source commit",
    lambda data: data["manifest"].__setitem__("sourceCommit", "0123456789abcdef0123456789abcdef01234567"),
)
expect_failure(
    "synthetic sourceRunID",
    lambda data: data["manifest"].__setitem__("sourceRunIDs", ["gh-963-source-run"]),
)
expect_failure(
    "fixed artifact bytes",
    lambda data: data["manifest"].__setitem__("artifactBytes", 512),
)
expect_failure(
    "missing manifest checksum",
    lambda data: data["manifest"].pop("manifestChecksum", None),
)
expect_failure(
    "production cutover true",
    lambda data: data["registry"].__setitem__("productionCutoverAuthorized", True),
)
expect_failure(
    "production endpoint true",
    lambda data: data["artifact"].__setitem__("productionEndpointConnected", True),
)
expect_failure(
    "bundle source run mismatch",
    lambda data: data["bundle"].__setitem__("sourceRunIDs", ["source-run-0000000000000000"]),
)
expect_failure(
    "missing bundle checksum chain",
    lambda data: data["bundle_manifest"].pop("bundleChecksum", None),
)

followup_snapshot = snapshot_for(followup_id)
validate_snapshot(followup_snapshot, followup_id)
PY

swift test --filter TargetGraphTests/testGH992ReadinessJSONInspectionGuardsValidateGeneratedEvidence

echo "MTPRO release v0.12.1 JSON inspection guard verification passed."
