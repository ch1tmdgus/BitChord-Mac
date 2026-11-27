<div align="center">

<img width="1920" height="1080" alt="BitChord desktop player screenshot" src="https://github.com/user-attachments/assets/4ae53a09-b7e7-4dc2-b676-d348401ce8ff" />

<br>
<br>
<br>

<h1>BitChord Mac</h1>

**A desktop music experience, refined.**

**BitChord Mac** is a community-maintained YouTube Music desktop app for macOS, based on BitChord Desktop Revived. It brings together a polished interface, immersive playback, and desktop-first controls.

![Status](https://img.shields.io/badge/status-revival%20in%20progress-DAA520?style=flat-square)
![Platforms](https://img.shields.io/badge/platform-macOS-6677AA?style=flat-square)
[![GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-555555?style=flat-square)](LICENSE)

[**Downloads**](#downloads) · [**Features**](#features) · [**Build**](#building-from-source) · [**Credits**](#credits--upstream)

</div>

> [!IMPORTANT]
> BitChord Mac is an independent macOS port of [BitChord Desktop Revived](https://github.com/Bntagaaa/BitChord-Desktop-Revived). The credits below acknowledge the upstream projects and contributors.

<div align="center">

<h2 id="features">✨ Highlights</h2>

- **Apple Music Experience** - A refined, modern interface featuring elegant frosted surfaces, adaptive blur, smooth animations, and seamless light/dark themes.
- **Immersive Music Visuals** - Bring your music to life with Spotify Canvas, Apple Music-inspired animated artist backgrounds, dynamic artwork colors, and beautifully synchronized lyrics.
- **A More Personal Player** - Enjoy a fullscreen listening experience, a resizable floating player, intuitive playback controls, and seamless queue management.
- **All Your Music, One Place** - Explore and stream through YouTube Music, access your Spotify library, discover new releases, and enjoy local music and offline downloads.
- **Powerful Audio Features** - Fine-tune your listening experience with an equalizer, crossfade, and advanced playback capabilities.
- **Connected Listening** - Stay connected with Discord Rich Presence, Last.fm and ListenBrainz scrobbling, and integrated music services.
- **Made for Desktop** - Designed for macOS with customizable interface options and in-app keyboard shortcuts for Quick Search and playback.
</div>

<div align="center">

<h2 id="downloads">Download BitChord Mac for macOS</h2>

[![Build macOS](https://img.shields.io/badge/download-macOS%20DMG-6677AA?style=for-the-badge)](https://github.com/ch1tmdgus/BitChord-Mac/actions/workflows/build-macos.yml)

Download the DMG artifact from a successful build. Choose `BitChord-macOS-arm64` for Apple Silicon or `BitChord-macOS-x64` for Intel. If no artifact is available, see the build instructions below.

**Note:** If you're looking for the Android APK, please download it from the [original BitChord repository](https://github.com/kushagrasinghx/BitChord/releases). This fork is focused on the desktop experience.

</div>

<div align="center">

<h2 id="building-from-source">⚙️ Build from source</h2>

</div>

**Requirements:** macOS, JDK 21, and Git.

```bash
./gradlew :desktopApp:run
./gradlew :desktopApp:packageDmg
```

The DMG is written to `desktopApp/build/compose/binaries/main/dmg/`. See [the macOS build guide](README-macos.md) for GitHub Actions instructions and current limitations.

<div align="center">

<h2 id="credits--upstream">📜 Credits and license</h2>

</div>

**BitChord Mac** builds on BitChord Desktop Revived, a community-maintained continuation of the original BitChord desktop application.

### Original Project

Special thanks to **[@kushagrasinghx](https://github.com/kushagrasinghx)**, the original creator of [BitChord](https://github.com/kushagrasinghx/BitChord), and all upstream contributors for building the foundation that made this project possible.

BitChord Mac keeps the upstream playback architecture, desktop improvements, and Visual Astra interface.

### Acknowledgements

We would also like to recognize the following projects and their contributors:

- **[BitChord](https://github.com/kushagrasinghx/BitChord)** — The original open-source project providing the core playback engine, music integrations, and application architecture.
- **[BitChord-PC-Continued](https://github.com/jackychan4891/BitChord-PC-Continued)** — Maintained by [@jackychan4891](https://github.com/jackychan4891) and its contributors. Portions of its Apple Music artist-motion implementation, including artwork metadata handling, HLS video selection, and playback improvements, have been adapted for Revived. See [PR #71](https://github.com/Bntagaaa/BitChord-Desktop-Revived/pull/71).
- **The open-source community** — Everyone who contributes code, reports issues, tests builds, or helps improve the project.

We sincerely appreciate the work and dedication of all developers whose contributions continue to make BitChord better.

### License

BitChord Mac is distributed under the **[GNU General Public License v3.0](LICENSE)**.

This project builds upon GPL-licensed source code from the original BitChord repository and compatible community forks. Original copyright notices and applicable license terms remain in effect.

You are free to use, study, modify, and redistribute the GPL-covered source code under the terms of the license. Distributed modifications must comply with the applicable GPL requirements.

Third-party libraries, fonts, artwork, and other assets may be subject to their own licenses and usage restrictions.

### Disclaimer

BitChord Mac is an **unofficial, independent community project**. It is not maintained, sponsored, or endorsed by the original BitChord developers or other referenced community forks.

This project is not affiliated with or endorsed by **YouTube, Google, Spotify, Apple**, or their respective subsidiaries. All trademarks and service names belong to their respective owners.
