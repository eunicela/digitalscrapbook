import SwiftUI

@main
struct DigitalScrapbookApp: App {
    @StateObject private var store = ScrapbookStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
