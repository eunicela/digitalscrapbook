import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrapbookLibraryView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScrapbookStore.preview)
}
