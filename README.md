<p align="center">
  <img src="docs/images/icon.png" alt="Wnotch icon" width="120" />
</p>

<h1 align="center">Wnotch</h1>

<p align="center">
  <b>Synced Spotify lyrics, right in your notch.</b><br/>
  A native macOS app that turns the notch into a live surface for lyrics, media, and system activity.
</p>

<p align="center">
  <b>English</b> · <a href="README.id.md">Bahasa Indonesia</a>
</p>

<p align="center">
  <a href="https://github.com/bagusmibr/Wnotch/releases/latest"><img src="https://img.shields.io/github/v/release/bagusmibr/Wnotch?style=for-the-badge&label=Download&color=0a84ff" alt="Latest release" /></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-black?style=for-the-badge&logo=apple&logoColor=white" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/Windows-coming%20soon-lightgrey?style=for-the-badge&logo=windows&logoColor=white" alt="Windows coming soon" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blueviolet?style=for-the-badge" alt="GPL-3.0" /></a>
</p>

<p align="center">
  <img src="docs/images/hero.png" alt="Wnotch showing a synced lyric line under the MacBook notch" width="100%" />
</p>

## Features

| | |
|---|---|
| 🎤 **Spotify lyrics** | While Spotify plays, the notch shows only the current lyric line, synced to the song, even after you skip forward or back. |
| 🕘 **Never empty** | Nothing playing? The notch shows the time and your battery level. |
| 🏝️ **Works without a notch** | On Macs without a notch and on external monitors, Wnotch floats as an island at the top of the screen. |
| 🎵 **Now Playing** | Media controls, artwork, and progress for Spotify, Apple Music and more. |
| ⚡ **Live activities** | Downloads, AirDrop, timers, screen recording, Focus, Personal Hotspot. |
| 🔋 **Alerts** | Charging, low/full battery, Bluetooth, Wi-Fi, VPN, plus custom volume and brightness HUDs. |
| 🌍 **39 languages** | Including English and Bahasa Indonesia. |

<p align="center">
  <img src="docs/images/lyrics-island.png" alt="Lyrics in the floating island on a Mac without a notch" width="49%" />
  <img src="docs/images/idle.png" alt="Clock and battery in the notch when nothing is playing" width="49%" />
</p>

<sub>Images are illustrations of the interface.</sub>

## Download

| Platform | Status |
|---|---|
| macOS 14 Sonoma or later | ✅ [Download the latest release](https://github.com/bagusmibr/Wnotch/releases/latest) |
| Windows | 🚧 Coming soon |

## Install (macOS)

1. Download `Wnotch.dmg` from [Releases](https://github.com/bagusmibr/Wnotch/releases/latest).
2. Open it and drag **Wnotch** into **Applications**.
3. Wnotch is not notarized by Apple yet, so remove the download quarantine once:
   ```bash
   xattr -dr com.apple.quarantine /Applications/Wnotch.app
   ```
4. Open Wnotch and allow the permissions it asks for:
   - **Automation → Spotify** to read the playback position for lyrics
   - **Accessibility** for the custom volume/brightness HUD

Lyrics can be turned on or off in **Settings → Now Playing → Spotify lyrics in notch**, and the idle clock in **Settings → Notch → Display**.

## FAQ

**Why do some songs show only the title?**
Lyrics come from the free [LRCLIB](https://lrclib.net) database. If a song is not there yet, Wnotch shows the song title instead.

**Does Wnotch collect any data?**
No. There is no account, analytics or tracking. Wnotch only contacts:
- [LRCLIB](https://lrclib.net) / [Lyrics.ovh](https://lyrics.ovh) to look up lyrics for the song that is playing
- `api.country.is` (fallback `ipapi.co`, `ipwho.is`) to show your VPN country, only when a VPN connects

## Build from source

Every push to `main` builds a DMG with GitHub Actions and runs the unit tests.

With Xcode:

```bash
git clone https://github.com/bagusmibr/Wnotch.git
cd Wnotch
./build_dmg.sh
```

## Acknowledgements

- [LRCLIB](https://lrclib.net) and [Lyrics.ovh](https://lyrics.ovh) for lyrics data
- [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter) (BSD-3-Clause) for Now Playing access
- [Lottie](https://github.com/airbnb/lottie-ios) and [Sparkle](https://sparkle-project.org)

## Developer

Made by **M** · [Website](https://portobagusmibr.vercel.app/) · [Instagram @bagusmibr](https://instagram.com/bagusmibr)

## License

[GPL-3.0](LICENSE)
