import SwiftUI
import UIKit

struct CardDetailView: View {
    let card: CollectorCard

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Frame \(card.number)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
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
                .background(.white, in: RoundedRectangle(cornerRadius: 22))
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
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundStyle(.archiveMuted)
                .frame(width: 110, alignment: .leading)

            Text(value)
                .font(.subheadline)
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
