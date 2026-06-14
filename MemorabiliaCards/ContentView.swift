import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: CardStore
    @State private var draftName = ""

    var body: some View {
        Group {
            if store.profile.displayName.isEmpty {
                onboarding
            } else {
                NavigationStack {
                    CollectionView()
                }
            }
        }
        .onAppear {
            draftName = store.profile.displayName
        }
    }

    private var onboarding: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("Memorabilia Cards")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    .foregroundStyle(.archiveInk)

                Text("Turn everyday finds into fixed-size vintage collector cards.")
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            VintageCollectorCardView(card: .sample)
                .frame(width: 230)
                .rotationEffect(.degrees(-3))
                .shadow(color: .black.opacity(0.18), radius: 22, y: 12)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("What name should appear on your cards?")
                    .font(.system(.headline, design: .rounded))

                TextField("Eunice Lai", text: $draftName)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .panelSurface(16)
            }

            Button {
                let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                store.updateProfileName(name.isEmpty ? "Collector" : name)
            } label: {
                Text("Start collecting")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.archiveInk, in: Capsule())
            }

            Spacer()
        }
        .padding(24)
        .background(Color.archiveBackground.ignoresSafeArea())
    }
}

extension Color {
    static let archiveBackground = Color.white
    static let archivePaper = Color(red: 0.98, green: 0.94, blue: 0.84)
    static let archiveInk = Color(red: 0.16, green: 0.15, blue: 0.12)
    static let archiveMuted = Color(red: 0.48, green: 0.43, blue: 0.34)
    static let archiveRed = Color(red: 0.56, green: 0.12, blue: 0.10)
    static let cardAccent = Color(red: 0.20, green: 0.45, blue: 0.95)
}

extension View {
    func panelSurface(_ cornerRadius: CGFloat = 16) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.archiveInk.opacity(0.10), lineWidth: 1)
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CardStore.preview)
}
