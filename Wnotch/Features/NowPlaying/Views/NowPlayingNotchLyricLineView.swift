//
//  NowPlayingNotchLyricLineView.swift
//  Wnotch
//
//  Single synced lyric line under the compact now-playing notch (Spotify).
//

import SwiftUI

struct NowPlayingNotchLyricLineView: View {
    @ObservedObject var nowPlayingViewModel: NowPlayingViewModel

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { context in
            let line = currentLine(at: context.date)
            Text(line)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(line)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.25), value: line)
        }
        .padding(.horizontal, 18)
        // Lyrics are fetched only while some view needs them (same mechanism as lock screen).
        // Detailed presentation turns on Spotify position polling so seeks resync quickly.
        .onAppear {
            nowPlayingViewModel.setLyricsPresentationActive(true, source: "spotifyNotch")
            nowPlayingViewModel.setDetailedPresentationActive(true, source: "spotifyNotch")
        }
        .onDisappear {
            nowPlayingViewModel.setLyricsPresentationActive(false, source: "spotifyNotch")
            nowPlayingViewModel.setDetailedPresentationActive(false, source: "spotifyNotch")
        }
    }

    private func currentLine(at date: Date) -> String {
        let title = nowPlayingViewModel.snapshot?.title ?? ""

        guard case .loaded(let lyrics) = nowPlayingViewModel.lyricsState else {
            return title
        }

        if let index = lyrics.activeLineIndex(at: nowPlayingViewModel.elapsedTime(at: date)),
           lyrics.lines.indices.contains(index) {
            let text = lyrics.lines[index].text.trimmingCharacters(in: .whitespaces)
            return text.isEmpty ? "♪" : text
        }

        // ponytail: unsynced lyrics only show the title; add plain-text scrolling if users ask.
        return title
    }
}

enum NowPlayingLyricsLayout {
    /// Wide enough for a typical lyric line; longer lines wrap to a second line.
    static let extraWidth: CGFloat = 300
    /// Strip under a physical notch: two 13pt lines + margins.
    static let stripHeight: CGFloat = 40
    /// Extra height for the floating pill on notchless screens.
    static let islandExtraHeight: CGFloat = 14
}

/// Lyrics-only compact layout: no artwork, no equalizer.
struct SpotifyLyricsNotchView: View {
    @Environment(\.isNotchlessScreen) private var isNotchlessScreen
    @ObservedObject var nowPlayingViewModel: NowPlayingViewModel

    var body: some View {
        if isNotchlessScreen {
            NowPlayingNotchLyricLineView(nowPlayingViewModel: nowPlayingViewModel)
                .padding(.vertical, 4)
        } else {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                NowPlayingNotchLyricLineView(nowPlayingViewModel: nowPlayingViewModel)
                    .frame(height: NowPlayingLyricsLayout.stripHeight - 6)
                    .padding(.bottom, 6)
            }
        }
    }
}
