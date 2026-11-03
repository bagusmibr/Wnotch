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
    
    /// Wnotch: while Spotify plays, the compact notch shows only the synced lyric line.
    @MainActor
    var showsSpotifyLyrics: Bool {
        settings.isSpotifyNotchLyricsEnabled &&
        nowPlayingViewModel.snapshot?.playbackSource?.preferredBundleIdentifier == "com.spotify.client"
    }

    func compactSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        // Physical notch hides the top band, so the lyric sits in a strip below it.
        showsSpotifyLyrics
            ? .init(width: baseWidth + 150, height: baseHeight + 24)
            : .init(width: baseWidth + 70, height: baseHeight)
    }
    
    func dynamicIslandSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        // No physical notch: the lyric fits inside the floating pill itself.
        .init(width: baseWidth + (showsSpotifyLyrics ? 200 : 65), height: baseHeight)
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
        guard showsSpotifyLyrics else {
            return AnyView(
                NowPlayingMinimalNotchView(
                    nowPlayingViewModel: nowPlayingViewModel,
                    settings: settings
                )
            )
        }

        return AnyView(SpotifyLyricsNotchView(nowPlayingViewModel: nowPlayingViewModel))
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
