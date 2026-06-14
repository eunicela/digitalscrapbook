import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var store: CardStore
    @State private var searchText = ""
    @State private var selectedType = "All"
    @State private var selectedCondition: CardCondition?
    @State private var showingMint = false
    @State private var showingFilters = false

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                if showingFilters {
                    filters
                }
                grid
            }
            .padding(18)
        }
        .background(Color.archiveBackground.ignoresSafeArea())
        .navigationTitle("Collection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingFilters.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingMint = true
                } label: {
                    Label("Mint", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingMint) {
            NavigationStack {
                MintCardView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("The Collection")
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                .foregroundStyle(.archiveInk)

            TextField("Search title, type, condition, notes", text: $searchText)
                .padding(12)
                .panelSurface(16)
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isActive: selectedType == "All") {
                        selectedType = "All"
                    }

                    ForEach(store.availableTypes, id: \.self) { type in
                        FilterChip(title: type, isActive: selectedType == type) {
                            selectedType = type
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Any condition", isActive: selectedCondition == nil) {
                        selectedCondition = nil
                    }

                    ForEach(CardCondition.allCases) { condition in
                        FilterChip(title: condition.displayName, isActive: selectedCondition == condition) {
                            selectedCondition = condition
                        }
                    }
                }
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 22) {
            ForEach(filteredCards) { card in
                NavigationLink {
                    CardDetailView(card: card)
                } label: {
                    VintageCollectorCardView(card: card, showLargeText: false)
                        .rotationEffect(.degrees(rotation(for: card)))
                        .shadow(color: .black.opacity(0.15), radius: 14, y: 9)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var filteredCards: [CollectorCard] {
        store.cards.filter { card in
            let matchesSearch = searchText.isEmpty ||
                card.title.localizedCaseInsensitiveContains(searchText) ||
                card.type.localizedCaseInsensitiveContains(searchText) ||
                card.condition.displayName.localizedCaseInsensitiveContains(searchText) ||
                card.notes.localizedCaseInsensitiveContains(searchText)

            let matchesType = selectedType == "All" || card.type == selectedType
            let matchesCondition = selectedCondition == nil || card.condition == selectedCondition

            return matchesSearch && matchesType && matchesCondition
        }
    }

    private func rotation(for card: CollectorCard) -> Double {
        let degrees = [-4.0, 2.5, -1.5, 4.0, -2.5, 1.0]
        return degrees[abs(card.id.hashValue) % degrees.count]
    }
}

private struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(isActive ? .white : .archiveInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isActive ? Color.cardAccent : Color.white, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.archiveInk.opacity(isActive ? 0 : 0.12), lineWidth: 1)
                }
        }
    }
}

#Preview {
    NavigationStack {
        CollectionView()
            .environmentObject(CardStore.preview)
    }
}
