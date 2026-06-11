# Digital Scrapbook

An iPhone-only SwiftUI prototype for a realistic, scrapbook-style photo journal.

## Current prototype

- Local scrapbook library with seeded sample content
- Realistic page-curl browsing via `UIPageViewController`
- Freeform page editor for a handmade scrapbook feel
- Add imported photos, captions, stickers, tape, date numbers, and paper scraps
- Drag, pinch-resize, rotate, delete, and reorder page elements
- Switch between paper backgrounds
- Persist scrapbook data locally as JSON in the app documents directory

## Open in Xcode

Open `DigitalScrapbook.xcodeproj`, choose an iPhone simulator, and run the
`DigitalScrapbook` target.

The app targets iOS 17 and uses SwiftUI plus a small UIKit bridge for the page
curl interaction.