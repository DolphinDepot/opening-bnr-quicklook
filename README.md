# Opening BNR Quick Look

[![Build](https://github.com/DolphinDepot/opening-bnr-quicklook/actions/workflows/build.yml/badge.svg)](https://github.com/DolphinDepot/opening-bnr-quicklook/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/DolphinDepot/opening-bnr-quicklook)](https://github.com/DolphinDepot/opening-bnr-quicklook/releases)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple)
![Universal](https://img.shields.io/badge/architecture-arm64%20%7C%20x86__64-lightgrey)
[![License: GPL-3.0](https://img.shields.io/github/license/DolphinDepot/opening-bnr-quicklook)](LICENSE)

A native macOS Quick Look extension for GameCube `opening.bnr` files. It decodes the 96×32 RGB5A3 banner, displays it at 4× size, and shows the BNR1 or BNR2 metadata.

Created by **webhdx**.

## Build and install

1. Open `OpeningBNRQuickLook.xcodeproj` in Xcode.
2. Select the **OpeningBNRQuickLook** target and choose your development team under Signing & Capabilities.
3. Build and run the app once.
4. If macOS asks, enable **Opening BNR Preview** in System Settings → General → Login Items & Extensions → Quick Look.
5. Select an `opening.bnr` file in Finder and press Space.

If Finder retains an old preview, run `qlmanage -r` and try again.

## Tests

Run `swift test` from the project directory. The parser tests do not require Xcode.

## Releasing

Push a semantic-version tag to build a universal `arm64` and `x86_64` app and create a GitHub release:

```sh
git tag v1.0.0
git push origin v1.0.0
```

Release builds are signed ad hoc, but are not notarized by Apple.

## License

Copyright © 2026 webhdx.

This project is licensed under the [GNU General Public License v3.0](LICENSE).
