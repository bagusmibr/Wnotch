import XCTest
@testable import Wnotch

final class PlaybackPositionResolverTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_000)

    func testStaleAppReadingDoesNotUndoSeek() {
        // AppleScript read at t0 said 30s; user then seeked to 120s, MediaRemote reports it at t0+5.
        XCTAssertFalse(PlaybackPositionResolver.shouldAdopt(
            appElapsed: 30, appReadAt: t0,
            snapshotElapsedAtAppRead: 115, snapshotReadAt: t0.addingTimeInterval(5),
            snapshotHasNoPosition: false))
    }

    func testFresherAppReadingCorrectsDrift() {
        XCTAssertTrue(PlaybackPositionResolver.shouldAdopt(
            appElapsed: 120, appReadAt: t0.addingTimeInterval(5),
            snapshotElapsedAtAppRead: 35, snapshotReadAt: t0,
            snapshotHasNoPosition: false))
    }

    func testSmallJitterIgnored() {
        XCTAssertFalse(PlaybackPositionResolver.shouldAdopt(
            appElapsed: 60.4, appReadAt: t0.addingTimeInterval(1),
            snapshotElapsedAtAppRead: 60, snapshotReadAt: t0,
            snapshotHasNoPosition: false))
    }

    func testMissingSnapshotPositionAlwaysAdopts() {
        XCTAssertTrue(PlaybackPositionResolver.shouldAdopt(
            appElapsed: 10, appReadAt: t0,
            snapshotElapsedAtAppRead: 0, snapshotReadAt: t0.addingTimeInterval(9),
            snapshotHasNoPosition: true))
    }
}
