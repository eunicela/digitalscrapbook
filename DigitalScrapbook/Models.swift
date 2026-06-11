import Foundation
import SwiftUI

struct Scrapbook: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var pages: [ScrapbookPage]

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        pages: [ScrapbookPage] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pages = pages
    }
}

struct ScrapbookPage: Identifiable, Codable, Equatable {
    var id: UUID
    var background: PageBackgroundStyle
    var elements: [ScrapbookElement]

    init(
        id: UUID = UUID(),
        background: PageBackgroundStyle = .warmPaper,
        elements: [ScrapbookElement] = []
    ) {
        self.id = id
        self.background = background
        self.elements = elements
    }
}

enum PageBackgroundStyle: String, CaseIterable, Codable, Identifiable {
    case warmPaper
    case blushStripe
    case blueGrid
    case kraft
    case mintDots

    var id: String { rawValue }

    var name: String {
        switch self {
        case .warmPaper:
            return "Warm paper"
        case .blushStripe:
            return "Blush stripes"
        case .blueGrid:
            return "Blue grid"
        case .kraft:
            return "Kraft paper"
        case .mintDots:
            return "Mint dots"
        }
    }
}

enum ScrapbookElementKind: String, Codable {
    case photo
    case text
    case sticker
    case tape
    case dateNumber
    case paperScrap
}

struct ScrapbookElement: Identifiable, Codable, Equatable {
    var id: UUID
    var kind: ScrapbookElementKind
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var rotationDegrees: Double
    var zIndex: Int
    var text: String
    var style: String

    init(
        id: UUID = UUID(),
        kind: ScrapbookElementKind,
        x: Double,
        y: Double,
        width: Double,
        height: Double,
        rotationDegrees: Double = 0,
        zIndex: Int = 0,
        text: String = "",
        style: String = ""
    ) {
        self.id = id
        self.kind = kind
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rotationDegrees = rotationDegrees
        self.zIndex = zIndex
        self.text = text
        self.style = style
    }
}

extension ScrapbookElement {
    static func handmadeRotation() -> Double {
        Double.random(in: -7...7)
    }

    static func photoPlaceholder(x: Double, y: Double, zIndex: Int) -> ScrapbookElement {
        ScrapbookElement(
            kind: .photo,
            x: x,
            y: y,
            width: 130,
            height: 100,
            rotationDegrees: handmadeRotation(),
            zIndex: zIndex,
            text: "Memory",
            style: "placeholder"
        )
    }

    static func text(_ text: String, x: Double, y: Double, zIndex: Int) -> ScrapbookElement {
        ScrapbookElement(
            kind: .text,
            x: x,
            y: y,
            width: 150,
            height: 54,
            rotationDegrees: handmadeRotation(),
            zIndex: zIndex,
            text: text,
            style: "caption"
        )
    }

    static func sticker(_ text: String, x: Double, y: Double, zIndex: Int) -> ScrapbookElement {
        ScrapbookElement(
            kind: .sticker,
            x: x,
            y: y,
            width: 54,
            height: 54,
            rotationDegrees: handmadeRotation(),
            zIndex: zIndex,
            text: text,
            style: "star"
        )
    }

    static func tape(x: Double, y: Double, zIndex: Int) -> ScrapbookElement {
        ScrapbookElement(
            kind: .tape,
            x: x,
            y: y,
            width: 92,
            height: 28,
            rotationDegrees: handmadeRotation(),
            zIndex: zIndex,
            style: "cream"
        )
    }

    static func dateNumber(_ text: String, x: Double, y: Double, zIndex: Int) -> ScrapbookElement {
        ScrapbookElement(
            kind: .dateNumber,
            x: x,
            y: y,
            width: 100,
            height: 88,
            rotationDegrees: -2,
            zIndex: zIndex,
            text: text,
            style: "blue"
        )
    }

    static func paperScrap(x: Double, y: Double, zIndex: Int) -> ScrapbookElement {
        ScrapbookElement(
            kind: .paperScrap,
            x: x,
            y: y,
            width: 160,
            height: 120,
            rotationDegrees: handmadeRotation(),
            zIndex: zIndex,
            text: "little moments",
            style: "redStripe"
        )
    }
}
