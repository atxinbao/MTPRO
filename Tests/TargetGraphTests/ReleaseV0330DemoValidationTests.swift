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
        XCTAssertEqual(
            ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: bundle).decision,
            .accepted
        )
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

        let readModel = ReleaseV0330DemoValidationStatusReadModel(
            report: ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: bundle)
        )
        XCTAssertTrue(readModel.readModelOnly)
        XCTAssertFalse(readModel.productionCutoverAuthorized)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
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
