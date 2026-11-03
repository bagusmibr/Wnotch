import XCTest
@testable import Wnotch

/// Inline controls (lyrics play/skip) must stop the notch-wide tap from also
/// expanding the notch or opening Spotify.
final class InlineControlTapClaimTests: XCTestCase {
    @MainActor
    func testNoClaimByDefault() {
        let viewModel = NotchViewModel(settings: TestNotchSettings(), hideDelay: 0.01, queueDelay: 0)
        TestLifetime.retain(viewModel)
        XCTAssertFalse(viewModel.didInlineControlClaimRecentTap)
    }

    @MainActor
    func testFreshControlTapIsClaimed() {
        let viewModel = NotchViewModel(settings: TestNotchSettings(), hideDelay: 0.01, queueDelay: 0)
        TestLifetime.retain(viewModel)
        viewModel.lastInlineControlTapDate = .now
        XCTAssertTrue(viewModel.didInlineControlClaimRecentTap)
    }

    @MainActor
    func testOldControlTapNoLongerBlocksNotchTaps() {
        let viewModel = NotchViewModel(settings: TestNotchSettings(), hideDelay: 0.01, queueDelay: 0)
        TestLifetime.retain(viewModel)
        viewModel.lastInlineControlTapDate = Date().addingTimeInterval(-2)
        XCTAssertFalse(viewModel.didInlineControlClaimRecentTap)
    }
}
