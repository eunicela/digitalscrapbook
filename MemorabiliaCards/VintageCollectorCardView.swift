import SwiftUI
import UIKit

enum CardLayout {
    static let aspectRatio: CGFloat = 2.5 / 3.5
    static let baseWidth: CGFloat = 300
    static let baseHeight: CGFloat = baseWidth / aspectRatio
}

struct VintageCollectorCardView: View {
    let card: CollectorCard
    var previewImage: UIImage?
    var showLargeText = true

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / CardLayout.baseWidth

            ZStack {
                cardSurface
                content
                    .padding(18)
            }
            .frame(width: CardLayout.baseWidth, height: CardLayout.baseHeight)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: proxy.size.width, height: proxy.size.width / CardLayout.aspectRatio, alignment: .topLeading)
        }
        .aspectRatio(CardLayout.aspectRatio, contentMode: .fit)
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.archiveInk.opacity(0.07), lineWidth: 1)
            }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            imageWindow
            footer
            notes
            Spacer(minLength: 0)
        }
        .foregroundStyle(.archiveInk)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(card.title)
                .font(.system(size: showLargeText ? 18 : 16, weight: .heavy, design: .rounded))
                .tracking(0.2)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(height: 46, alignment: .topLeading)

            Spacer(minLength: 4)

            statusDots
                .padding(.top, 4)
        }
    }

    private var statusDots: some View {
        HStack(spacing: 5) {
            Circle().fill(Color.archiveInk.opacity(0.22)).frame(width: 9, height: 9)
            Circle().fill(Color.cardAccent).frame(width: 9, height: 9)
            Circle().fill(Color.archiveInk).frame(width: 9, height: 9)
        }
    }

    private var imageWindow: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(imageBackdrop)
            .overlay {
                Group {
                    if let image = previewImage ?? ImageStorage.image(named: card.imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholderImage
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .frame(height: 150)
    }

    private var placeholderImage: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 30, weight: .semibold))
            Text("MEMORABILIA")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.8)
        }
        .foregroundStyle(Color.archiveInk.opacity(0.35))
    }

    private var footer: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 1) {
                Text("DIGITAL")
                Text("SCRAPBOOK")
                Text("#\(String(format: "%03d", card.number)) · SER \(card.series)")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.archiveMuted)
                    .padding(.top, 3)
            }
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .tracking(0.4)

            Rectangle()
                .fill(Color.archiveInk.opacity(0.10))
                .frame(width: 1)

            VStack(alignment: .leading, spacing: 6) {
                ModernRow(label: "FOUND", value: card.discoveredDate.formatted(date: .numeric, time: .omitted))
                ModernRow(label: "BY", value: card.discoveredBy)
                ModernRow(label: "TYPE", value: card.type)
                ModernRow(label: "COND", value: card.condition.displayName)
            }
        }
    }

    private var notes: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("NOTES")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.5)
                .foregroundStyle(.archiveMuted)

            Text(card.notes.isEmpty ? "No notes recorded." : card.notes)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 2)
    }

    private var imageBackdrop: Color {
        switch card.condition {
        case .pristine:
            return Color(red: 0.90, green: 0.95, blue: 0.99)
        case .excellent:
            return Color(red: 0.92, green: 0.96, blue: 0.93)
        case .good:
            return Color(red: 0.98, green: 0.95, blue: 0.89)
        case .worn:
            return Color(red: 0.98, green: 0.93, blue: 0.91)
        case .old:
            return Color(red: 0.95, green: 0.93, blue: 0.98)
        }
    }
}

private struct ModernRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.5)
                .foregroundStyle(.archiveMuted)
                .frame(width: 42, alignment: .leading)

            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    VintageCollectorCardView(card: .sample)
        .frame(width: 300)
        .padding()
        .background(Color(white: 0.95))
}
