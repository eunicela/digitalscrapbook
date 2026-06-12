import Foundation

@MainActor
final class ScrapbookStore: ObservableObject {
    @Published var scrapbooks: [Scrapbook] = []

    private let fileURL: URL

    init(fileURL: URL = ScrapbookStore.defaultFileURL) {
        self.fileURL = fileURL
        load()
    }

    static var preview: ScrapbookStore {
        let store = ScrapbookStore(fileURL: URL(fileURLWithPath: "/dev/null"))
        store.scrapbooks = [Scrapbook.sample]
        return store
    }

    func createScrapbook(title: String) {
        let page = ScrapbookPage(background: .warmPaper)
        let scrapbook = Scrapbook(title: title, pages: [page])
        scrapbooks.insert(scrapbook, at: 0)
        save()
    }

    func addPage(to scrapbookID: UUID) {
        guard let scrapbookIndex = scrapbooks.firstIndex(where: { $0.id == scrapbookID }) else {
            return
        }

        let nextBackground = PageBackgroundStyle.allCases[scrapbooks[scrapbookIndex].pages.count % PageBackgroundStyle.allCases.count]
        scrapbooks[scrapbookIndex].pages.append(ScrapbookPage(background: nextBackground))
        scrapbooks[scrapbookIndex].updatedAt = .now
        save()
    }

    func deleteScrapbook(id: UUID) {
        scrapbooks.removeAll { $0.id == id }
        save()
    }

    func updatePage(_ page: ScrapbookPage, scrapbookID: UUID) {
        guard
            let scrapbookIndex = scrapbooks.firstIndex(where: { $0.id == scrapbookID }),
            let pageIndex = scrapbooks[scrapbookIndex].pages.firstIndex(where: { $0.id == page.id })
        else {
            return
        }

        scrapbooks[scrapbookIndex].pages[pageIndex] = page
        scrapbooks[scrapbookIndex].updatedAt = .now
        save()
    }

    func save() {
        do {
            let data = try JSONEncoder.scrapbookEncoder.encode(scrapbooks)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Unable to save scrapbooks: \(error.localizedDescription)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            scrapbooks = try JSONDecoder.scrapbookDecoder.decode([Scrapbook].self, from: data)
        } catch {
            scrapbooks = [Scrapbook.sample]
            save()
        }
    }

    private static var defaultFileURL: URL {
        URL.documentsDirectory.appending(path: "scrapbooks.json")
    }
}

private extension JSONEncoder {
    static var scrapbookEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var scrapbookDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension Scrapbook {
    static let sample = {
        Scrapbook(
            title: "Paper Memories",
            pages: [
                ScrapbookPage(
                    background: .warmPaper,
                    elements: [
                        .dateNumber("2", x: 74, y: 124, zIndex: 1),
                        .dateNumber("26", x: 86, y: 252, zIndex: 2),
                        .photoPlaceholder(x: 214, y: 176, zIndex: 3),
                        .sticker("★", x: 116, y: 222, zIndex: 4),
                        .sticker("✦", x: 282, y: 122, zIndex: 5),
                        .tape(x: 212, y: 126, zIndex: 6),
                        .text("favorite little everyday things", x: 216, y: 84, zIndex: 7)
                    ]
                ),
                ScrapbookPage(
                    background: .blushStripe,
                    elements: [
                        .paperScrap(x: 204, y: 198, zIndex: 1),
                        .photoPlaceholder(x: 186, y: 170, zIndex: 2),
                        .photoPlaceholder(x: 258, y: 250, zIndex: 3),
                        .tape(x: 176, y: 112, zIndex: 4),
                        .sticker("✶", x: 116, y: 132, zIndex: 5),
                        .sticker("♡", x: 306, y: 302, zIndex: 6),
                        .text("remember this", x: 252, y: 104, zIndex: 7)
                    ]
                ),
                ScrapbookPage(
                    background: .blueGrid,
                    elements: [
                        .paperScrap(x: 116, y: 196, zIndex: 1),
                        .photoPlaceholder(x: 220, y: 206, zIndex: 2),
                        .text("freeform pages, stickers, tape, dates", x: 184, y: 84, zIndex: 3),
                        .sticker("✿", x: 92, y: 318, zIndex: 4),
                        .tape(x: 246, y: 140, zIndex: 5)
                    ]
                )
            ]
        )
    }()
}
