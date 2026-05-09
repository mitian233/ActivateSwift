# ActivateSwift

A Swift/AppKit rewrite of [ActivateMac](https://github.com/Lakr233/ActivateMac) — the "Activate Windows" watermark ported to macOS.

This project was created as a learning exercise to rewrite an Objective-C macOS application in Swift using AppKit.

![macOS](https://img.shields.io/badge/macOS-11.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## What It Does

Displays the iconic "Activate Windows" watermark as a transparent overlay on every connected display. The watermark:

- Sits at the highest window level, above all other windows (including on the lock screen via [SkyLightWindow](https://github.com/Lakr233/SkyLightWindow))
- Ignores mouse events — you can click right through it
- Joins all Spaces/desktops
- Adjusts text based on macOS version (Ventura 13.0+ uses different wording)
- Adapts font size to screen resolution

## Build & Run

```bash
# Clone
git clone https://github.com/mitian233/ActivateSwift.git
cd ActivateSwift

# Open in Xcode
open ActivateSwift.xcodeproj

# Build and run (Cmd+R)
```

## Project Structure

```
ActivateSwift/
├── main.swift              # All app code in one file (5 classes)
├── Activate.entitlements
├── Assets.xcassets/
└── *.lproj/                # 8 localizations (de, en, ja, pl, ru, tr, zh-Hans, zh-Hant)
```

## Architecture

The app is intentionally structured as a single `main.swift` file with 5 classes, matching the original single-file Objective-C architecture:

| Class                 | Role                                                                           |
| --------------------- | ------------------------------------------------------------------------------ |
| `AppDelegate`         | App lifecycle, sets activation policy to hide dock icon                        |
| `AppWindow`           | Borderless, transparent, always-on-top `NSWindow`                              |
| `AppWindowController` | Manages window placement per screen                                            |
| `AppController`       | Entry point — creates controllers for all screens, listens for display changes |
| `AppView`             | Custom `NSView` that draws the watermark text                                  |

## Dependencies

- [SkyLightWindow](https://github.com/Lakr233/SkyLightWindow) v1.0.0 — Uses Apple's private SkyLight framework to elevate windows above the lock screen. MIT licensed.

## Acknowledgements

- **[ActivateMac](https://github.com/ActivateLinux/Lakr233)** by [@Lakr233](https://github.com/Lakr233) — The original Objective-C implementation this project is based on. MIT License, Copyright (c) 2022 Lakr Aream.
- **[SkyLightWindow](https://github.com/Lakr233/SkyLightWindow)** by [@Lakr233](https://github.com/Lakr233) — Private SkyLight API wrapper for elevated window placement. MIT License.

## License

MIT License — same as the original [ActivateMac](https://github.com/ActivateLinux/ActivateMac) project.
