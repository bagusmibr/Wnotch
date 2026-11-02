import SwiftUI
internal import AppKit

enum NowPlayingEvent: Equatable {
    case started
    case stopped
    case playbackStateChanged(isPlaying: Bool)
}

struct NowPlayingNotchContent: NotchContentProtocol, DynamicIslandCustomizable {
    let id = NotchContentRegistry.Media.nowPlaying.id
    let nowPlayingViewModel: NowPlayingViewModel
    let settings: MediaAndFilesSettingsStore
    let applicationSettings: ApplicationSettingsStore
    let onOpenPlaybackSource: @MainActor () -> Void

    init(
        nowPlayingViewModel: NowPlayingViewModel,
        settings: MediaAndFilesSettingsStore,
        applicationSettings: ApplicationSettingsStore,
        onOpenPlaybackSource: @escaping @MainActor () -> Void = {}
    ) {
        self.nowPlayingViewModel = nowPlayingViewModel
        self.settings = settings
        self.applicationSettings = applicationSettings
        self.onOpenPlaybackSource = onOpenPlaybackSource
    }
    
    var priority: Int { NotchContentRegistry.Media.nowPlaying.priority }
    
    var isExpandable: Bool { true }

    var windowLink: (@MainActor () -> Void)? {
        guard nowPlayingViewModel.canOpenPlaybackSource else { return nil }

        return {
            nowPlayingViewModel.openPlaybackSource()
        }
    }
    
    /// Wnotch: show a synced lyric line under the notch while Spotify is the source.
    @MainActor
    var showsSpotifyLyrics: Bool {
        settings.isSpotifyNotchLyricsEnabled &&
        nowPlayingViewModel.snapshot?.playbackSource?.preferredBundleIdentifier == "com.spotify.client"
    }

    private var lyricsExtraHeight: CGFloat {
        showsSpotifyLyrics ? 22 : 0
    }

    private var lyricsExtraWidth: CGFloat {
        showsSpotifyLyrics ? 150 : 0
    }

    func compactSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        .init(width: baseWidth + max(70, lyricsExtraWidth), height: baseHeight + lyricsExtraHeight)
    }
    
    func dynamicIslandSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        .init(width: baseWidth + max(65, lyricsExtraWidth), height: baseHeight + lyricsExtraHeight)
    }
    
    func expandedSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        .init(width: baseWidth + 190, height: baseHeight + 160)
    }
    
    func expandedDynamicIslandSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        .init(width: baseWidth + 260, height: baseHeight + 150)
    }
    
    func expandedCornerRadius(baseRadius: CGFloat) -> (top: CGFloat, bottom: CGFloat) {
        (top: 34, bottom: 44)
    }

    func dynamicIslandCornerRadius(baseHeight: CGFloat) -> CGFloat {
        baseHeight * 0.5
    }

    func expandedDynamicIslandCornerRadius(baseHeight: CGFloat) -> CGFloat {
        baseHeight * 0.2
    }
    
    @MainActor
    func compactView() -> AnyView {
        let minimal = NowPlayingMinimalNotchView(
            nowPlayingViewModel: nowPlayingViewModel,
            settings: settings
        )

        guard showsSpotifyLyrics else { return AnyView(minimal) }

        return AnyView(
            VStack(spacing: 0) {
                minimal.frame(maxHeight: .infinity)
                NowPlayingNotchLyricLineView(nowPlayingViewModel: nowPlayingViewModel)
                    .frame(height: 22)
                    .padding(.bottom, 4)
            }
        )
    }
    
    @MainActor
    func expandedView() -> AnyView {
        AnyView(
            NowPlayingExpandedNotchView(
                nowPlayingViewModel: nowPlayingViewModel,
                settings: settings,
                applicationSettings: applicationSettings,
                onOpenPlaybackSource: onOpenPlaybackSource
            )
        )
    }
}
