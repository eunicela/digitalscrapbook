import SwiftUI
import UIKit

struct CardDetailView: View {
    let card: CollectorCard

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("FRAME \(card.number)")
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .tracking(1)
                    .foregroundStyle(.archiveMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VintageCollectorCardView(card: card)
                    .frame(width: min(UIScreen.main.bounds.width - 48, 330))
                    .shadow(color: .black.opacity(0.18), radius: 24, y: 15)

                VStack(alignment: .leading, spacing: 10) {
                    DetailLine(label: "Series", value: "\(card.series)")
                    DetailLine(label: "Number", value: "#\(String(format: "%03d", card.number))")
                    DetailLine(label: "Condition", value: card.condition.displayName)
                    DetailLine(label: "Type", value: card.type)
                    DetailLine(label: "Discovered", value: card.discoveredDate.formatted(date: .long, time: .omitted))
                    DetailLine(label: "Discovered by", value: card.discoveredBy)
                }
                .padding(16)
                .panelSurface(22)
            }
            .padding(20)
        }
        .background(Color.archiveBackground.ignoresSafeArea())
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DetailLine: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(.archiveMuted)
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.archiveInk)

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: .sample)
    }
}
