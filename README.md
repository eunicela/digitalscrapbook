# Memorabilia Cards

An iPhone-only SwiftUI prototype for turning everyday memorabilia into fixed-size
vintage collector cards.

## Current prototype

- Onboarding for the collector name used as `Discovered by`
- Collection grid with lightly scattered fixed-ratio card previews
- Search plus filters for type and condition
- Mint flow with camera or photo library input
- Editable suggested title
- Preset and custom types
- Automatic discovered date and discovered by
- Random final condition assignment on mint
- Series and card numbering
- Single front-side vintage archive/field-note card template
- Local JSON metadata persistence and local image storage

## Open in Xcode

Open `MemorabiliaCards.xcodeproj`, choose an iPhone simulator or device, and run
the `MemorabiliaCards` target.

The app targets iOS 17 and uses SwiftUI with PhotosUI plus a UIKit camera bridge.
