import Foundation
import UIKit

@MainActor
final class CardStore: ObservableObject {
    @Published var cards: [CollectorCard] = []
    @Published var profile: UserProfile = .empty

    private let cardsURL: URL
    private let profileURL: URL

    init(
        cardsURL: URL = URL.documentsDirectory.appending(path: "collector-cards.json"),
        profileURL: URL = URL.documentsDirectory.appending(path: "profile.json")
    ) {
        self.cardsURL = cardsURL
        self.profileURL = profileURL
        load()
    }

    static var preview: CardStore {
        let store = CardStore(
            cardsURL: URL(fileURLWithPath: "/dev/null"),
            profileURL: URL(fileURLWithPath: "/dev/null")
        )
        store.profile = UserProfile(displayName: "Eunice Lai", customTypes: ["Doors"])
        store.cards = [
            .sample,
            CollectorCard(
                title: "Red Mountain Postcard",
                imagePath: "",
                discoveredBy: "Eunice Lai",
                condition: .worn,
                type: "Book/Print",
                notes: "A faded print with the perfect amount of field-note energy.",
                series: 1,
                number: 2
            ),
            CollectorCard(
                title: "Sidewalk Wildflower",
                imagePath: "",
                discoveredBy: "Eunice Lai",
                condition: .old,
                type: "Nature",
                notes: "Pressed-looking petals near the corner cafe.",
                series: 1,
                number: 3
            )
        ]
        return store
    }

    var availableTypes: [String] {
        Array(Set(CardTypeDefaults.presets + profile.customTypes)).sorted()
    }

    var nextCardNumber: Int {
        (cards.map(\.number).max() ?? 0) + 1
    }

    func updateProfileName(_ name: String) {
        profile.displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        saveProfile()
    }

    func addCustomType(_ type: String) {
        let trimmed = type.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        if !profile.customTypes.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            profile.customTypes.append(trimmed)
            saveProfile()
        }
    }

    func mintCard(title: String, image: UIImage, type: String, notes: String) throws -> CollectorCard {
        let filename = try ImageStorage.save(image)
        let now = Date()
        let card = CollectorCard(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Find" : title,
            imagePath: filename,
            discoveredDate: now,
            discoveredBy: profile.displayName.isEmpty ? "Collector" : profile.displayName,
            condition: .mintedRandom(),
            type: type,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            series: 1,
            number: nextCardNumber,
            createdAt: now
        )

        cards.insert(card, at: 0)
        saveCards()
        return card
    }

    private func load() {
        loadProfile()
        loadCards()
    }

    private func loadProfile() {
        do {
            let data = try Data(contentsOf: profileURL)
            profile = try JSONDecoder.cardDecoder.decode(UserProfile.self, from: data)
        } catch {
            profile = .empty
        }
    }

    private func loadCards() {
        do {
            let data = try Data(contentsOf: cardsURL)
            cards = try JSONDecoder.cardDecoder.decode([CollectorCard].self, from: data)
        } catch {
            cards = [.sample]
            saveCards()
        }
    }

    private func saveCards() {
        do {
            let data = try JSONEncoder.cardEncoder.encode(cards)
            try data.write(to: cardsURL, options: [.atomic])
        } catch {
            assertionFailure("Unable to save cards: \(error.localizedDescription)")
        }
    }

    private func saveProfile() {
        do {
            let data = try JSONEncoder.cardEncoder.encode(profile)
            try data.write(to: profileURL, options: [.atomic])
        } catch {
            assertionFailure("Unable to save profile: \(error.localizedDescription)")
        }
    }
}

private extension JSONEncoder {
    static var cardEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var cardDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
