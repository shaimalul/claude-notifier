@testable import ClaudeNotifier
import XCTest

final class CustomActionTests: XCTestCase {
    // MARK: - Kind.requiresForeground

    func test_showIDE_requiresForeground() {
        XCTAssertTrue(CustomAction.Kind.showIDE.requiresForeground)
    }

    func test_otherKinds_doNotRequireForeground() {
        let backgroundKinds: [CustomAction.Kind] = [
            .copyCwd, .openTerminal, .revealInFinder,
            .snooze5m, .snooze15m, .snooze60m
        ]
        for kind in backgroundKinds {
            XCTAssertFalse(kind.requiresForeground, "\(kind) should not require foreground")
        }
    }

    // MARK: - Kind.displayName

    func test_displayNames_areNotEmpty() {
        for kind in CustomAction.Kind.allCases {
            XCTAssertFalse(kind.displayName.isEmpty, "\(kind) has empty displayName")
        }
    }

    func test_showIDE_displayName() {
        XCTAssertEqual(CustomAction.Kind.showIDE.displayName, "Show IDE")
    }

    func test_copyCwd_displayName() {
        XCTAssertEqual(CustomAction.Kind.copyCwd.displayName, "Copy Path")
    }

    // MARK: - Codable

    func test_codableRoundTrip() throws {
        let action = CustomAction(id: "test-id", title: "My Action", kind: .openTerminal)
        let data = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(CustomAction.self, from: data)
        XCTAssertEqual(action, decoded)
    }

    func test_allCasesHaveUniqueRawValues() {
        let rawValues = CustomAction.Kind.allCases.map(\.rawValue)
        let unique = Set(rawValues)
        XCTAssertEqual(rawValues.count, unique.count)
    }
}
