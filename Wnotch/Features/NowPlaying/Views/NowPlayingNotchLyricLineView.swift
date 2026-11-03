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
    /// Row of previous / play-pause / next above the lyric.
    static let controlsHeight: CGFloat = 30
}

/// Lyrics layout: optional music controls on top, the synced lyric below. No artwork, no equalizer.
struct SpotifyLyricsNotchView: View {
    @Environment(\.isNotchlessScreen) private var isNotchlessScreen
    @ObservedObject var nowPlayingViewModel: NowPlayingViewModel
    var showsControls: Bool = true
    var onControlTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            if !isNotchlessScreen {
                // Top band sits behind the physical notch; keep content below it.
                Spacer(minLength: 0)
            }

            if showsControls {
                NowPlayingNotchInlineControls(
                    nowPlayingViewModel: nowPlayingViewModel,
                    onControlTap: onControlTap
                )
                .frame(height: NowPlayingLyricsLayout.controlsHeight)
            }

            NowPlayingNotchLyricLineView(nowPlayingViewModel: nowPlayingViewModel)
                .frame(height: isNotchlessScreen ? nil : NowPlayingLyricsLayout.stripHeight - 6)
                .frame(maxHeight: isNotchlessScreen ? .infinity : nil)
                .padding(.bottom, isNotchlessScreen ? 4 : 6)
        }
        .padding(.top, isNotchlessScreen ? 4 : 0)
    }
}

/// Compact previous / play-pause / next row for the lyrics notch.
struct NowPlayingNotchInlineControls: View {
    @ObservedObject var nowPlayingViewModel: NowPlayingViewModel
    let onControlTap: () -> Void

    var body: some View {
        HStack(spacing: 28) {
            control("backward.fill", size: 14, label: "Previous track") {
                nowPlayingViewModel.previousTrack()
            }
            control(
                nowPlayingViewModel.snapshot?.isPlaying == true ? "pause.fill" : "play.fill",
                size: 18,
                label: nowPlayingViewModel.snapshot?.isPlaying == true ? "Pause" : "Play"
            ) {
                nowPlayingViewModel.togglePlayPause()
            }
            control("forward.fill", size: 14, label: "Next track") {
                nowPlayingViewModel.nextTrack()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func control(_ symbol: String, size: CGFloat, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.white)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 30, height: 26)
                .contentShape(Rectangle())
        }
        .buttonStyle(InlineControlButtonStyle())
        .accessibilityLabel(label)
        // Claim the press as soon as it starts, before the notch-wide gesture can
        // expand (press-and-hold) or open Spotify (click) on release.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in onControlTap() }
        )
    }
}

private struct InlineControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1)
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
