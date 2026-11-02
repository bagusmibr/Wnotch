//
//  InactiveLyricsProvider.swift
//  Wnotch
//
//  Created by M on 5/13/26.
//

import Foundation

@MainActor
final class InactiveLyricsProvider: LyricsProviding {
    func lyrics(for snapshot: NowPlayingSnapshot) async throws -> TrackLyrics? {
        nil
    }
}
