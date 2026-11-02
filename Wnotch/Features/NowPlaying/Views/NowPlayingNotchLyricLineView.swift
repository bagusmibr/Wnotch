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
        TimelineView(.periodic(from: .now, by: 0.25)) { context in
            let line = currentLine(at: context.date)
            Text(line)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .id(line)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.25), value: line)
        }
        .padding(.horizontal, 14)
        // Lyrics are fetched only while some view needs them (same mechanism as lock screen).
        .onAppear { nowPlayingViewModel.setLyricsPresentationActive(true, source: "spotifyNotch") }
        .onDisappear { nowPlayingViewModel.setLyricsPresentationActive(false, source: "spotifyNotch") }
    }

    private func currentLine(at date: Date) -> String {
        guard case .loaded(let lyrics) = nowPlayingViewModel.lyricsState else {
            return nowPlayingViewModel.snapshot?.title ?? ""
        }

        if let index = lyrics.activeLineIndex(at: nowPlayingViewModel.elapsedTime(at: date)),
           lyrics.lines.indices.contains(index) {
            let text = lyrics.lines[index].text.trimmingCharacters(in: .whitespaces)
            return text.isEmpty ? "♪" : text
        }

        // ponytail: unsynced lyrics only show the title; add plain-text scrolling if users ask.
        return nowPlayingViewModel.snapshot?.title ?? ""
    }
}
