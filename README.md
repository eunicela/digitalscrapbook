# Digital Scrapbook

An Expo React Native prototype for a scrapbook-style photo journal that can be
tested directly on an iPhone with Expo Go.

## Current prototype

- Local scrapbook library with seeded sample content
- Phone-friendly page browsing with a tactile animated page flip
- Freeform page editor for a handmade scrapbook feel
- Add imported photos, captions, stickers, tape, date numbers, and paper scraps
- Drag elements around the page
- Resize, rotate, delete, and reorder selected elements
- Switch between paper backgrounds
- Persist scrapbook data locally with AsyncStorage

## Test on your iPhone

1. Install **Expo Go** from the App Store.
2. Install project dependencies:

   ```bash
   npm install
   ```

3. Start the dev server with a tunnel:

   ```bash
   npm run start:tunnel
   ```

4. Scan the QR code with your iPhone camera or Expo Go.

The tunnel mode is the easiest option when your phone and computer are not on
the same Wi-Fi network.

## Useful commands

```bash
npm start
npm run start:tunnel
npm run typecheck
```