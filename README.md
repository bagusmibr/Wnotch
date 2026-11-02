<p align="center">
  <img src="Wnotch/Resources/Assets.xcassets/AppIcon.appiconset/logo256.png" alt="Wnotch" width="128" />
</p>

<h1 align="center">Wnotch</h1>

<p align="center">Turn your MacBook notch into a live surface, with synced Spotify lyrics right under the notch.</p>

## Features

- **Spotify lyrics in the notch**: while Spotify is playing, the current synced lyric line appears under the notch and follows the song. Toggle it in Settings → Now Playing.
- **Now Playing**: media controls, artwork, audio visualizer, progress bar.
- **Live activities**: downloads, AirDrop, timer, screen recording, Focus, Personal Hotspot, lock screen media.
- **Alerts**: battery charging/low/full, Bluetooth, Wi-Fi, VPN, custom volume and brightness HUD.
- **Gestures**: swipe to dismiss/restore, trackpad and mouse controls.
- **Notchless displays**: renders as a floating capsule on Macs without a notch and on external monitors.
- **39 languages**, including Bahasa Indonesia.

## Install

1. Download `Wnotch.dmg` from [Releases](https://github.com/bagusmibr/Wnotch/releases) (or the latest build under Actions).
2. Drag `Wnotch` into `Applications`.
3. Remove the quarantine flag (the app is not notarized):
   ```bash
   xattr -dr com.apple.quarantine /Applications/Wnotch.app
   ```
4. Launch Wnotch and grant the permissions you need (Accessibility for the HUD, Automation for Spotify).

## Requirements

- macOS 14.0 or later

## Build

Every push to `main` builds a DMG with GitHub Actions (`.github/workflows/build.yml`).

Locally, with Xcode:

```bash
git clone https://github.com/bagusmibr/Wnotch.git
cd Wnotch
./build_dmg.sh
```

## Acknowledgements

- [LRCLIB](https://lrclib.net) and [Lyrics.ovh](https://lyrics.ovh) for lyrics data.
- [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter) (BSD-3-Clause) for Now Playing access.
- [Lottie](https://github.com/airbnb/lottie-ios) and [Sparkle](https://sparkle-project.org).

## Developer

M · [Website](https://portobagusmibr.vercel.app/) · [Instagram @bagusmibr](https://instagram.com/bagusmibr)

## License

GPL-3.0. See [LICENSE](LICENSE).
