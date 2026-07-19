import ExecutionClient
import Dashboard
import XCTest

final class ReleaseV0330DemoValidationTests: XCTestCase {
    func testGH1546DemoBundleRequiresBothProductsAndTrustedProvenance() throws {
        let sourceCommit = String(repeating: "a", count: 40)
        let spot = try productEvidence(.spot, sourceCommit: sourceCommit, runID: 1_001)
        let futures = try productEvidence(.usdsPerpetual, sourceCommit: sourceCommit, runID: 1_002)
        let bundle = try ReleaseV0330DemoValidationEvidenceBundle(
            sourceCommit: sourceCommit,
            products: [spot, futures],
            createdAtEpochSeconds: 1_800_000_000
        )

        XCTAssertTrue(bundle.boundaryHeld)
        XCTAssertTrue(try bundle.canonicalSHA256().hasPrefix("sha256:"))
        let report = ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: bundle)
        XCTAssertEqual(report.decision, .accepted)
        XCTAssertEqual(
            report.backendClosureDecision,
            ReleaseV0330DemoValidationDecisionReport
                .acceptedDemoNetworkParityBackendClosure
        )
        XCTAssertFalse(report.productionCutoverAuthorized)
        XCTAssertFalse(report.defaultProductionTradingEnabled)
    }

    func testGH1547DemoDecisionFailsClosedForProductionFlagDrift() throws {
        let sourceCommit = String(repeating: "b", count: 40)
        let spot = try productEvidence(.spot, sourceCommit: sourceCommit, runID: 2_001)
        let futures = try productEvidence(.usdsPerpetual, sourceCommit: sourceCommit, runID: 2_002)
        let bundle = try ReleaseV0330DemoValidationEvidenceBundle(
            sourceCommit: sourceCommit,
            products: [spot, futures],
            createdAtEpochSeconds: 1_800_000_000,
            productionCutoverAuthorized: true
        )

        let report = ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: bundle)
        XCTAssertEqual(report.decision, .blocked)
        XCTAssertEqual(report.backendClosureDecision, "blocked")
        XCTAssertFalse(report.productionCutoverAuthorized)
        XCTAssertFalse(report.defaultProductionTradingEnabled)
    }

    func testGH1548DemoStatusCLIAndDashboardRemainReadOnly() throws {
        let sourceCommit = String(repeating: "c", count: 40)
        let bundle = try ReleaseV0330DemoValidationEvidenceBundle(
            sourceCommit: sourceCommit,
            products: [
                try productEvidence(.spot, sourceCommit: sourceCommit, runID: 3_001),
                try productEvidence(.usdsPerpetual, sourceCommit: sourceCommit, runID: 3_002),
            ],
            createdAtEpochSeconds: 1_800_000_000
        )
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("v0330-demo-bundle-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        try JSONEncoder().encode(bundle).write(to: url, options: .withoutOverwriting)

        let snapshot = ReleaseV0330DemoValidationArtifactValidator.validate(bundleURL: url)
        let readModel = ReleaseV0330DemoValidationStatusReadModel(snapshot: snapshot)
        XCTAssertTrue(readModel.readModelOnly)
        XCTAssertEqual(
            readModel.backendClosureDecision,
            ReleaseV0330DemoValidationDecisionReport
                .acceptedDemoNetworkParityBackendClosure
        )
        XCTAssertFalse(readModel.productionCutoverAuthorized)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testGH1577DemoArtifactValidatorFailsClosedForMissingCorruptAndIncompleteBundles() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("v0330-validator-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let missing = ReleaseV0330DemoValidationArtifactValidator.validate(
            bundleURL: root.appendingPathComponent("missing.json")
        )
        XCTAssertEqual(missing.decision, .blocked)
        XCTAssertEqual(missing.reasons, ["missing-demo-validation-bundle"])

        let corruptURL = root.appendingPathComponent("corrupt.json")
        try Data("{not-json".utf8).write(to: corruptURL)
        let corrupt = ReleaseV0330DemoValidationArtifactValidator.validate(bundleURL: corruptURL)
        XCTAssertEqual(corrupt.decision, .blocked)
        XCTAssertEqual(corrupt.reasons, ["corrupt-demo-validation-bundle"])

        let sourceCommit = String(repeating: "d", count: 40)
        let complete = try ReleaseV0330DemoValidationEvidenceBundle(
            sourceCommit: sourceCommit,
            products: [
                try productEvidence(.spot, sourceCommit: sourceCommit, runID: 4_001),
                try productEvidence(.usdsPerpetual, sourceCommit: sourceCommit, runID: 4_002),
            ],
            createdAtEpochSeconds: 1_800_000_000
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(complete))
                as? [String: Any]
        )
        object["products"] = [try XCTUnwrap((object["products"] as? [[String: Any]])?.first)]
        let incompleteURL = root.appendingPathComponent("incomplete.json")
        try JSONSerialization.data(withJSONObject: object).write(to: incompleteURL)

        let incomplete = ReleaseV0330DemoValidationArtifactValidator.validate(
            bundleURL: incompleteURL
        )
        XCTAssertEqual(incomplete.decision, .blocked)
        XCTAssertEqual(incomplete.reasons, ["demo-validation-bundle-boundary-failed"])
        XCTAssertFalse(incomplete.productionCutoverAuthorized)
        XCTAssertFalse(incomplete.defaultProductionTradingEnabled)

        var provenanceDrift = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(complete))
                as? [String: Any]
        )
        var products = try XCTUnwrap(provenanceDrift["products"] as? [[String: Any]])
        var firstProduct = products[0]
        var provenance = try XCTUnwrap(firstProduct["provenance"] as? [String: Any])
        provenance["workflowName"] = "local-manifest"
        firstProduct["provenance"] = provenance
        products[0] = firstProduct
        provenanceDrift["products"] = products
        let provenanceDriftURL = root.appendingPathComponent("provenance-drift.json")
        try JSONSerialization.data(withJSONObject: provenanceDrift).write(
            to: provenanceDriftURL
        )

        let drifted = ReleaseV0330DemoValidationArtifactValidator.validate(
            bundleURL: provenanceDriftURL
        )
        XCTAssertEqual(drifted.decision, .blocked)
        XCTAssertEqual(drifted.reasons, ["demo-validation-bundle-boundary-failed"])
    }

    func testGH1577DemoArtifactValidatorRejectsSymlinkEscape() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory
            .appendingPathComponent("v0330-root-\(UUID().uuidString)", isDirectory: true)
        let outside = fileManager.temporaryDirectory
            .appendingPathComponent("v0330-outside-\(UUID().uuidString).json")
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: root)
            try? fileManager.removeItem(at: outside)
        }
        try Data("{}".utf8).write(to: outside)
        let link = root.appendingPathComponent("bundle.json")
        try fileManager.createSymbolicLink(at: link, withDestinationURL: outside)

        let snapshot = ReleaseV0330DemoValidationArtifactValidator.validate(bundleURL: link)
        XCTAssertEqual(snapshot.decision, .blocked)
        XCTAssertEqual(snapshot.reasons, ["unsafe-demo-validation-artifact-path"])
        XCTAssertTrue(snapshot.boundaryHeld)
    }

    private func productEvidence(
        _ product: ReleaseV0330CanaryProduct,
        sourceCommit: String,
        runID: Int
    ) throws -> ReleaseV0330DemoValidationProductEvidence {
        let host = ReleaseV0330CanaryEnvironment.demo.endpointHost(for: product)
        let actions: [ReleaseV0320CanaryAction] = [.submit, .status, .cancel]
        let observations = actions.map { action in
            ReleaseV0330ObservedCanaryTransportObservation(
                runID: "demo-\(runID)",
                product: product,
                action: action,
                environment: .demo,
                requestID: "request-\(action.rawValue)",
                redactedOrderReference: "sha256:\(String(repeating: "1", count: 64))",
                endpointHost: host,
                artifact: ReleaseV0330ObservedCanaryArtifactReference(
                    relativePath: "operations/\(product.rawValue)-\(action.rawValue).json",
                    sha256: "sha256:\(String(repeating: "2", count: 64))"
                ),
                rawSecretPersisted: false,
                rawResponsePersisted: false
            )
        }
        let evidence = ReleaseV0330ObservedCanaryRunEvidence(
            runID: "demo-\(runID)",
            sourceCommit: sourceCommit,
            product: product,
            environment: .demo,
            symbol: "BTCUSDT",
            approvalPacketID: "packet-\(runID)",
            executionAuthorizationRecordID: "authorization-\(runID)",
            observations: observations,
            runLockReleased: true,
            productionCutoverAuthorized: false,
            defaultProductionTradingEnabled: false
        )
        let provenance = try ReleaseV0330DemoValidationProvenance(
            repository: "atxinbao/MTPRO",
            workflowName: "MTPRO v0.33.0 Binance Demo Canary Validation",
            runID: runID,
            runURL: "https://github.com/atxinbao/MTPRO/actions/runs/\(runID)",
            artifactName: "v0330-\(product.rawValue)-demo-evidence-\(runID)",
            artifactSHA256: "sha256:\(String(repeating: "3", count: 64))",
            sourceCommit: sourceCommit,
            retrievedAtEpochSeconds: 1_800_000_001
        )
        return try ReleaseV0330DemoValidationProductEvidence(
            product: product,
            runEvidence: evidence,
            provenance: provenance
        )
    }
}
