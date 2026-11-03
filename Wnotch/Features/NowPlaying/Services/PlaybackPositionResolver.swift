//
//  PlaybackPositionResolver.swift
//  Wnotch
//

import Foundation

/// Decides whether a position read from the player app (AppleScript) should replace the
/// MediaRemote position. Only a *fresher* reading may win: a cached reading taken before
/// the user seeked in Spotify must never pull the position back.
enum PlaybackPositionResolver {
    static func shouldAdopt(
        appElapsed: TimeInterval,
        appReadAt: Date,
        snapshotElapsedAtAppRead: TimeInterval,
        snapshotReadAt: Date,
        snapshotHasNoPosition: Bool,
        tolerance: TimeInterval = 1.0
    ) -> Bool {
        if snapshotHasNoPosition { return true }
        guard appReadAt > snapshotReadAt else { return false }
        return abs(appElapsed - snapshotElapsedAtAppRead) > tolerance
    }
}
