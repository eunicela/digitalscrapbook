import PhotosUI
import SwiftUI
import UIKit

struct MintCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CardStore

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var title = ""
    @State private var selectedType = CardTypeDefaults.presets[0]
    @State private var customType = ""
    @State private var notes = ""
    @State private var showingCamera = false
    @State private var mintedCard: CollectorCard?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                photoSection
                detailsSection
                previewSection
                mintButton
            }
            .padding(20)
        }
        .background(Color.archiveBackground.ignoresSafeArea())
        .navigationTitle("Mint Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { image in
                selectedImage = image
                suggestTitleIfNeeded()
            }
        }
        .sheet(item: $mintedCard) { card in
            MintRevealView(card: card) {
                dismiss()
            }
        }
        .alert("Could not mint card", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                await loadPhoto(from: newItem)
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memorabilia photo")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.archiveInk)

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.archiveInk.opacity(0.10), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 42))
                        Text("Take or choose a photo")
                            .font(.headline)
                    }
                    .foregroundStyle(.archiveMuted)
                    .frame(height: 220)
                }
            }
            .frame(height: 220)
            .clipped()

            HStack(spacing: 12) {
                Button {
                    showingCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cardAccent)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Library", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Details")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.archiveInk)

            TextField("Suggested title", text: $title)
                .textInputAutocapitalization(.words)
                .padding(12)
                .panelSurface(14)

            Picker("Type", selection: $selectedType) {
                ForEach(store.availableTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(.menu)
            .tint(.archiveInk)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .panelSurface(14)

            HStack {
                TextField("Add custom type", text: $customType)
                    .textInputAutocapitalization(.words)
                    .padding(12)
                    .panelSurface(14)

                Button("Add") {
                    let trimmed = customType.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.addCustomType(trimmed)
                    if !trimmed.isEmpty {
                        selectedType = trimmed
                    }
                    customType = ""
                }
                .buttonStyle(.bordered)
            }

            TextField("Field notes about this find", text: $notes, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .panelSurface(14)

            Text("Discovered date and discovered by are automatic. Condition is randomly assigned once when minted.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fixed-size preview")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.archiveInk)

            VintageCollectorCardView(card: previewCard, previewImage: selectedImage)
                .frame(width: min(UIScreen.main.bounds.width - 60, 290))
                .frame(maxWidth: .infinity)
        }
    }

    private var mintButton: some View {
        Button {
            mint()
        } label: {
            Text("Mint Card")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selectedImage == nil ? Color.gray : Color.archiveInk, in: Capsule())
        }
        .disabled(selectedImage == nil)
    }

    private var previewCard: CollectorCard {
        CollectorCard(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? suggestedTitle : title,
            imagePath: "",
            discoveredDate: .now,
            discoveredBy: store.profile.displayName.isEmpty ? "Collector" : store.profile.displayName,
            condition: .excellent,
            type: selectedType,
            notes: notes.isEmpty ? "Field notes will appear here." : notes,
            series: 1,
            number: store.nextCardNumber
        )
    }

    private var suggestedTitle: String {
        "\(selectedType) Find #\(String(format: "%03d", store.nextCardNumber))"
    }

    @MainActor
    private func loadPhoto(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) else {
                return
            }
            selectedImage = image
            selectedPhotoItem = nil
            suggestTitleIfNeeded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func suggestTitleIfNeeded() {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            title = suggestedTitle
        }
    }

    private func mint() {
        guard let selectedImage else {
            return
        }

        do {
            let card = try store.mintCard(
                title: title.isEmpty ? suggestedTitle : title,
                image: selectedImage,
                type: selectedType,
                notes: notes
            )
            mintedCard = card
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct MintRevealView: View {
    let card: CollectorCard
    let done: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Text("Minted")
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                .foregroundStyle(.archiveInk)

            Text("Condition revealed: \(card.condition.displayName)")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.archiveMuted)

            VintageCollectorCardView(card: card)
                .frame(width: min(UIScreen.main.bounds.width - 54, 310))
                .shadow(color: .black.opacity(0.18), radius: 24, y: 15)

            Button {
                done()
            } label: {
                Text("Add to Collection")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.archiveInk, in: Capsule())
            }
            .padding(.horizontal, 24)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.archiveBackground)
    }
}

#Preview {
    NavigationStack {
        MintCardView()
            .environmentObject(CardStore.preview)
    }
}
