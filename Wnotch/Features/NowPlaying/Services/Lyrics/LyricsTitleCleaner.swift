//
//  LyricsTitleCleaner.swift
//  Wnotch
//
//  Spotify track titles often carry suffixes that lyrics databases don't index.
//

import Foundation

enum LyricsTitleCleaner {
    /// Patterns (case-insensitive) stripped from the end of a title.
    private static let suffixPatterns = [
        // "Song - From "Movie" Soundtrack", "Song - Remastered 2011", "Song - Live at X", "Song - Radio Edit"
        #"\s+-\s+(from|remaster|remastered|live|radio edit|single version|album version|mono|stereo|bonus|acoustic|demo|edit|version|\d{4} remaster).*$"#,
        // "Song (feat. X)", "Song (with X)", "Song [Remastered]", "Song (From "Movie")"
        #"\s*[\(\[](feat\.?|ft\.?|with|from|remaster|remastered|live|radio edit|prod\.?|bonus|explicit|clean|acoustic|\d{4} remaster)[^\)\]]*[\)\]]"#
    ]

    static func cleanedTitle(_ title: String) -> String {
        var result = title
        for pattern in suffixPatterns {
            result = result.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
        }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? title : result
    }

    /// First artist only: "A, B & C" -> "A".
    static func primaryArtist(_ artist: String) -> String {
        let first = artist.components(separatedBy: CharacterSet(charactersIn: ",&;"))
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? artist
        return first.isEmpty ? artist : first
    }

    /// Ordered, de-duplicated (title, artist) pairs to try.
    static func searchPairs(title: String, artist: String) -> [(title: String, artist: String)] {
        let cleaned = cleanedTitle(title)
        let mainArtist = primaryArtist(artist)
        var seen = Set<String>()
        return [(title, artist), (cleaned, artist), (cleaned, mainArtist)].filter {
            seen.insert("\($0.title.lowercased())|\($0.artist.lowercased())").inserted
        }
    }

    static func searchVariants(for snapshot: NowPlayingSnapshot) -> [NowPlayingSnapshot] {
        searchPairs(title: snapshot.title, artist: snapshot.artist).map {
            snapshot.settingLookupMetadata(title: $0.title, artist: $0.artist)
        }
    }
}
