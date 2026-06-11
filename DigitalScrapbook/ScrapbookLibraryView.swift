import SwiftUI

struct ScrapbookLibraryView: View {
    @EnvironmentObject private var store: ScrapbookStore
    @State private var newTitle = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                createCard
                scrapbookGrid
            }
            .padding(20)
        }
        .background(Color.scrapbookInk.ignoresSafeArea())
        .navigationTitle("Scrapbooks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.scrapbookInk, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Digital Scrapbook")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Flip through handmade pages, then customize every photo, note, sticker, and scrap.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var createCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start a new book")
                .font(.headline)

            HStack(spacing: 10) {
                TextField("Weekend memories", text: $newTitle)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16))

                Button {
                    let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.createScrapbook(title: title.isEmpty ? "Untitled Scrapbook" : title)
                    newTitle = ""
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(Color.scrapbookCoral, in: Circle())
                }
                .accessibilityLabel("Create scrapbook")
            }
        }
        .padding(16)
        .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.18), radius: 24, y: 14)
    }

    private var scrapbookGrid: some View {
        LazyVStack(spacing: 18) {
            ForEach(store.scrapbooks) { scrapbook in
                NavigationLink {
                    PageFlipView(scrapbookID: scrapbook.id)
                } label: {
                    ScrapbookCard(scrapbook: scrapbook)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        store.deleteScrapbook(id: scrapbook.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

private struct ScrapbookCard: View {
    let scrapbook: Scrapbook

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.94, green: 0.91, blue: 0.84))
                    .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 8)

                if let firstPage = scrapbook.pages.first {
                    PagePreview(page: firstPage, pageNumber: 1, totalPages: scrapbook.pages.count)
                        .scaleEffect(0.33)
                        .frame(width: 86, height: 118)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Rectangle()
                    .fill(.black.opacity(0.1))
                    .frame(width: 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .frame(width: 96, height: 128)

            VStack(alignment: .leading, spacing: 8) {
                Text(scrapbook.title)
                    .font(.title3.bold())
                    .foregroundStyle(.scrapbookInk)

                Text("\(scrapbook.pages.count) \(scrapbook.pages.count == 1 ? "page" : "pages")")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(scrapbook.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 26))
        .shadow(color: .black.opacity(0.16), radius: 18, y: 10)
    }
}

extension Color {
    static let scrapbookInk = Color(red: 0.22, green: 0.27, blue: 0.42)
    static let scrapbookCoral = Color(red: 0.94, green: 0.18, blue: 0.30)
    static let scrapbookBlue = Color(red: 0.24, green: 0.40, blue: 0.78)
    static let scrapbookPaper = Color(red: 0.96, green: 0.94, blue: 0.89)
}

#Preview {
    NavigationStack {
        ScrapbookLibraryView()
            .environmentObject(ScrapbookStore.preview)
    }
}
