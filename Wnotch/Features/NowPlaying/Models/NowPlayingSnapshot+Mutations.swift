//
//  NowPlayingSnapshot+Mutations.swift
//  Wnotch
//

import Foundation

extension NowPlayingSnapshot {
    var favoriteTrackKey: String? {
        let components = [title.trimmed, artist.trimmed, album.trimmed]
        let joined = components.joined(separator: "|")
        return joined.replacingOccurrences(of: "|", with: "").isEmpty ? nil : joined
    }

    func togglingPlaybackState() -> Self {
        Self(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime(at: .now),
            playbackRate: isPlaying ? 0 : 1,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: .now
        )
    }

    func settingPlaybackRate(_ newPlaybackRate: Double) -> Self {
        Self(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime(at: .now),
            playbackRate: newPlaybackRate,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: .now
        )
    }

    /// Copy used only for lyrics lookups (cleaned title / primary artist).
    func settingLookupMetadata(title newTitle: String, artist newArtist: String) -> Self {
        Self(
            title: newTitle,
            artist: newArtist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime,
            playbackRate: playbackRate,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: refreshedAt
        )
    }

    func settingElapsedTime(_ newElapsedTime: TimeInterval) -> Self {
        Self(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: min(max(newElapsedTime, 0), duration > 0 ? duration : newElapsedTime),
            playbackRate: playbackRate,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: .now
        )
    }

    func settingShuffle(_ isShuffled: Bool) -> Self {
        Self(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime(at: .now),
            playbackRate: playbackRate,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: .now
        )
    }

    func settingRepeatMode(_ repeatMode: NowPlayingRepeatMode) -> Self {
        Self(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime(at: .now),
            playbackRate: playbackRate,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: .now
        )
    }

    func settingVolume(_ volume: Double) -> Self {
        Self(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            elapsedTime: elapsedTime(at: .now),
            playbackRate: playbackRate,
            artworkData: artworkData,
            playbackSource: playbackSource,
            mediaType: mediaType,
            contentItemIdentifier: contentItemIdentifier,
            isShuffled: isShuffled,
            repeatMode: repeatMode,
            volume: volume,
            isFavorite: isFavorite,
            supportsFavorite: supportsFavorite,
            supportsVolumeControl: supportsVolumeControl,
            refreshedAt: .now
        )
    }
}
