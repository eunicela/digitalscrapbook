import Foundation

struct CollectorCard: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var imagePath: String
    var discoveredDate: Date
    var discoveredBy: String
    var condition: CardCondition
    var type: String
    var notes: String
    var series: Int
    var number: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        imagePath: String,
        discoveredDate: Date = .now,
        discoveredBy: String,
        condition: CardCondition,
        type: String,
        notes: String,
        series: Int = 1,
        number: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.imagePath = imagePath
        self.discoveredDate = discoveredDate
        self.discoveredBy = discoveredBy
        self.condition = condition
        self.type = type
        self.notes = notes
        self.series = series
        self.number = number
        self.createdAt = createdAt
    }
}

enum CardCondition: String, CaseIterable, Codable, Identifiable {
    case pristine
    case excellent
    case good
    case worn
    case old

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pristine:
            return "Pristine"
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .worn:
            return "Worn"
        case .old:
            return "Old"
        }
    }

    static func mintedRandom() -> CardCondition {
        allCases.randomElement() ?? .good
    }
}

struct UserProfile: Codable, Equatable {
    var displayName: String
    var customTypes: [String]

    static let empty = UserProfile(displayName: "", customTypes: [])
}

enum CardTypeDefaults {
    static let presets = [
        "Nature",
        "Place",
        "Object",
        "Words",
        "Vehicle",
        "Food/Drink",
        "Ticket/Event",
        "Art",
        "Book/Print",
        "Clothing",
        "Found Item",
        "Other"
    ]
}

extension CollectorCard {
    static let sample = CollectorCard(
        title: "A Plum Door Against Yellow Bricks",
        imagePath: "",
        discoveredDate: Date(timeIntervalSince1970: 1_718_064_000),
        discoveredBy: "Eunice Lai",
        condition: .pristine,
        type: "Place",
        notes: "A cute plum colored door found while taking a walk in Noe Valley.",
        series: 1,
        number: 1
    )
}
