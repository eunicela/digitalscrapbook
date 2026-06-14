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
                cardPaper
                fixedContent
                    .padding(18)
                ConditionOverlay(condition: card.condition)
                    .allowsHitTesting(false)
            }
            .frame(width: CardLayout.baseWidth, height: CardLayout.baseHeight)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: proxy.size.width, height: proxy.size.width / CardLayout.aspectRatio, alignment: .topLeading)
        }
        .aspectRatio(CardLayout.aspectRatio, contentMode: .fit)
    }

    private var cardPaper: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(conditionPaper)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.archiveInk.opacity(0.28), lineWidth: 1)
                    .padding(9)
            }
            .overlay {
                PaperGrain(opacity: card.condition == .pristine ? 0.02 : 0.06)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
    }

    private var fixedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            title
            imageWindow
            metadata
            notes
            Spacer(minLength: 0)
        }
        .fontDesign(.serif)
        .foregroundStyle(.archiveInk)
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("SERIES \(card.series)")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(1.1)

            Spacer()

            Text("#\(String(format: "%03d", card.number))")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(1.1)
        }
        .foregroundStyle(.archiveMuted)
    }

    private var title: some View {
        Text(card.title)
            .font(.system(size: showLargeText ? 19 : 17, weight: .semibold, design: .serif))
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .frame(height: 48, alignment: .topLeading)
    }

    private var imageWindow: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.62))
                .overlay {
                    Rectangle()
                        .stroke(Color.archiveInk.opacity(0.18), lineWidth: 1)
                }

            if let image = previewImage ?? ImageStorage.image(named: card.imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                placeholderImage
            }
        }
        .frame(height: 164)
        .clipped()
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.81, green: 0.75, blue: 0.59),
                    Color(red: 0.51, green: 0.58, blue: 0.50),
                    Color(red: 0.30, green: 0.36, blue: 0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "camera.macro")
                    .font(.system(size: 34, weight: .medium))
                Text("MEMORABILIA")
                    .font(.system(size: 11, weight: .black, design: .serif))
                    .tracking(1.5)
            }
            .foregroundStyle(.white.opacity(0.84))
        }
    }

    private var metadata: some View {
        VStack(spacing: 7) {
            MetadataRow(label: "Discovered", value: card.discoveredDate.formatted(date: .abbreviated, time: .omitted))
            MetadataRow(label: "Discovered by", value: card.discoveredBy)
            MetadataRow(label: "Condition", value: card.condition.displayName)
            MetadataRow(label: "Type", value: card.type)
        }
        .font(.system(size: 11, weight: .regular, design: .serif))
    }

    private var notes: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes")
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(1.1)
                .foregroundStyle(.archiveMuted)

            Text(card.notes.isEmpty ? "No notes recorded." : card.notes)
                .font(.system(size: 12, weight: .regular, design: .serif))
                .lineLimit(3)
                .minimumScaleFactor(0.88)
                .frame(height: 44, alignment: .topLeading)
        }
        .padding(.top, 3)
    }

    private var conditionPaper: Color {
        switch card.condition {
        case .pristine:
            return Color(red: 0.99, green: 0.96, blue: 0.86)
        case .excellent:
            return Color.archivePaper
        case .good:
            return Color(red: 0.95, green: 0.90, blue: 0.78)
        case .worn:
            return Color(red: 0.90, green: 0.83, blue: 0.68)
        case .old:
            return Color(red: 0.83, green: 0.75, blue: 0.57)
        }
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(label)
                .fontWeight(.bold)
                .foregroundStyle(.archiveMuted)
                .frame(width: 78, alignment: .leading)

            Text(value)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
    }
}

private struct PaperGrain: View {
    let opacity: Double

    var body: some View {
        Canvas { context, size in
            for index in 0..<160 {
                let x = Double((index * 37) % Int(max(size.width, 1)))
                let y = Double((index * 53) % Int(max(size.height, 1)))
                let rect = CGRect(x: x, y: y, width: 1.2, height: 1.2)
                context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(opacity)))
            }
        }
    }
}

private struct ConditionOverlay: View {
    let condition: CardCondition

    var body: some View {
        ZStack {
            switch condition {
            case .pristine:
                LinearGradient(
                    colors: [.white.opacity(0.02), .white.opacity(0.32), .white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)
            case .excellent:
                EmptyView()
            case .good:
                scuffs.opacity(0.18)
            case .worn:
                scuffs.opacity(0.28)
                edgeWear.opacity(0.32)
            case .old:
                scuffs.opacity(0.38)
                edgeWear.opacity(0.48)
                Rectangle().fill(Color.brown.opacity(0.08))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var scuffs: some View {
        Canvas { context, size in
            for index in 0..<28 {
                var path = Path()
                let x = CGFloat((index * 31) % Int(size.width))
                let y = CGFloat((index * 47) % Int(size.height))
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x + CGFloat(12 + index % 11), y: y + CGFloat(index % 5)))
                context.stroke(path, with: .color(.archiveInk.opacity(0.28)), lineWidth: 0.7)
            }
        }
    }

    private var edgeWear: some View {
        RoundedRectangle(cornerRadius: 4)
            .strokeBorder(Color.archiveInk.opacity(0.22), lineWidth: 14)
            .blur(radius: 8)
    }
}

#Preview {
    VintageCollectorCardView(card: .sample)
        .frame(width: 300)
        .padding()
        .background(Color.archiveBackground)
}
