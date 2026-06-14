import SwiftUI

@main
struct MemorabiliaCardsApp: App {
    @StateObject private var store = CardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
