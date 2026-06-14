# AGENTS.md

## Cursor Cloud specific instructions

### Project overview
`digitalscrapbook` is an **iPhone-only SwiftUI app** ("Memorabilia Cards") that turns
photos of memorabilia into fixed-size vintage collector cards. The application code is an
Xcode project (`MemorabiliaCards.xcodeproj`) targeting **iOS 17**, using SwiftUI, PhotosUI,
and a UIKit camera bridge.

### Important environment limitation (read first)
This project **cannot be built or run on Cursor Cloud agent VMs**, which are Linux x86_64.
Building/running requires **macOS with Xcode** and an iPhone simulator or device. There is
no Linux toolchain that can compile an `.xcodeproj` SwiftUI/iOS app (no Xcode, no iOS SDK,
SwiftUI is Apple-platform only). Do not spend effort trying to install Swift on Linux to
build this — it will not work for an iOS/SwiftUI Xcode target.

- **Build/run/test:** Open `MemorabiliaCards.xcodeproj` in Xcode on macOS, select an iPhone
  simulator (or device), and run the `MemorabiliaCards` target. (See the project README on
  the relevant branch for details.)
- There are **no Linux dependencies to install** and **no services to start** — so the
  update script is intentionally a no-op.

### Note on branch state
The `main` branch may contain only `README.md`; the actual app code lives on feature
branches/PRs (e.g. the SwiftUI prototype). Check the relevant PR branch for the source.
