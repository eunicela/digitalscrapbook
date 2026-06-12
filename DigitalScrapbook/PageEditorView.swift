import PhotosUI
import SwiftUI

struct PageEditorView: View {
    @EnvironmentObject private var store: ScrapbookStore
    let scrapbookID: UUID
    let pageID: UUID

    private var pageBinding: Binding<ScrapbookPage>? {
        guard
            let scrapbookIndex = store.scrapbooks.firstIndex(where: { $0.id == scrapbookID }),
            let pageIndex = store.scrapbooks[scrapbookIndex].pages.firstIndex(where: { $0.id == pageID })
        else {
            return nil
        }

        return Binding {
            store.scrapbooks[scrapbookIndex].pages[pageIndex]
        } set: { page in
            store.updatePage(page, scrapbookID: scrapbookID)
        }
    }

    var body: some View {
        Group {
            if let pageBinding {
                PageCanvasEditor(page: pageBinding)
            } else {
                ContentUnavailableView("Page not found", systemImage: "doc")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PageCanvasEditor: View {
    @Binding var page: ScrapbookPage
    @State private var selectedElementID: UUID?
    @State private var pickerItem: PhotosPickerItem?

    private let canvasSize = CGSize(width: 340, height: 460)

    var body: some View {
        VStack(spacing: 0) {
            canvas

            if let selectedElement {
                selectedInspector(for: selectedElement)
            }

            Divider()
            addToolbar
            backgroundToolbar
        }
        .background(Color(red: 0.13, green: 0.14, blue: 0.14).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Customize Page")
                    .font(.headline)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    deleteSelectedElement()
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(selectedElementID == nil)
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                await importPhoto(from: newItem)
                await MainActor.run {
                    pickerItem = nil
                }
            }
        }
    }

    private var canvas: some View {
        GeometryReader { proxy in
            let scale = min(
                (proxy.size.width - 32) / canvasSize.width,
                (proxy.size.height - 32) / canvasSize.height
            )

            ZStack {
                Color.scrapbookInk.opacity(0.42)
                    .ignoresSafeArea()

                ZStack {
                    PageBackground(style: page.background)

                    ForEach(page.elements.sorted { $0.zIndex < $1.zIndex }) { element in
                        if let binding = binding(for: element) {
                            EditableElementLayer(
                                element: binding,
                                selectedElementID: $selectedElementID
                            )
                        }
                    }
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(.black.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.30), radius: 26, y: 18)
                .scaleEffect(scale)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var addToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    toolbarButton("Photo", systemImage: "photo.on.rectangle")
                }

                Button {
                    addElement(.text("new little note", x: 170, y: 180, zIndex: nextZIndex()))
                } label: {
                    toolbarButton("Text", systemImage: "textformat")
                }

                Button {
                    addElement(.sticker(["★", "✦", "♡", "✿"].randomElement() ?? "★", x: 170, y: 180, zIndex: nextZIndex()))
                } label: {
                    toolbarButton("Sticker", systemImage: "star.fill")
                }

                Button {
                    addElement(.tape(x: 170, y: 180, zIndex: nextZIndex()))
                } label: {
                    toolbarButton("Tape", systemImage: "rectangle.roundedtop")
                }

                Button {
                    addElement(.dateNumber("26", x: 170, y: 190, zIndex: nextZIndex()))
                } label: {
                    toolbarButton("Date", systemImage: "number")
                }

                Button {
                    addElement(.paperScrap(x: 170, y: 200, zIndex: nextZIndex()))
                } label: {
                    toolbarButton("Scrap", systemImage: "note.text")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(red: 0.18, green: 0.18, blue: 0.17))
    }

    private var backgroundToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Text("Paper")
                    .font(.footnote.bold())
                    .foregroundStyle(.white.opacity(0.72))

                ForEach(PageBackgroundStyle.allCases) { style in
                    Button {
                        page.background = style
                    } label: {
                        Text(style.name)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(page.background == style ? .scrapbookInk : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(page.background == style ? Color.white : Color.white.opacity(0.13), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(red: 0.14, green: 0.14, blue: 0.13))
    }

    private func selectedInspector(for selected: Binding<ScrapbookElement>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Selected \(selected.wrappedValue.kind.rawValue)")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.72))

                Spacer()

                Button {
                    sendSelectedBackward()
                } label: {
                    Image(systemName: "square.2.layers.3d.bottom.filled")
                }

                Button {
                    bringSelectedForward()
                } label: {
                    Image(systemName: "square.2.layers.3d.top.filled")
                }
            }

            if selected.wrappedValue.kind != .photo && selected.wrappedValue.kind != .tape {
                TextField("Text", text: selected.text)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(14)
        .background(Color(red: 0.17, green: 0.17, blue: 0.16))
    }

    private func toolbarButton(_ title: String, systemImage: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.headline)
            Text(title)
                .font(.caption2.bold())
        }
        .foregroundStyle(.white)
        .frame(width: 66, height: 58)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    }

    private var selectedElement: Binding<ScrapbookElement>? {
        guard
            let selectedElementID,
            let index = page.elements.firstIndex(where: { $0.id == selectedElementID })
        else {
            return nil
        }

        return Binding {
            page.elements[index]
        } set: { updatedElement in
            page.elements[index] = updatedElement
        }
    }

    private func binding(for element: ScrapbookElement) -> Binding<ScrapbookElement>? {
        guard let index = page.elements.firstIndex(where: { $0.id == element.id }) else {
            return nil
        }

        return Binding {
            page.elements[index]
        } set: { updatedElement in
            page.elements[index] = updatedElement
        }
    }

    private func addElement(_ element: ScrapbookElement) {
        page.elements.append(element)
        selectedElementID = element.id
    }

    private func deleteSelectedElement() {
        guard let selectedElementID else {
            return
        }
        page.elements.removeAll { $0.id == selectedElementID }
        self.selectedElementID = nil
    }

    private func bringSelectedForward() {
        guard let selectedElementID, let index = page.elements.firstIndex(where: { $0.id == selectedElementID }) else {
            return
        }
        page.elements[index].zIndex = nextZIndex()
    }

    private func sendSelectedBackward() {
        guard let selectedElementID, let index = page.elements.firstIndex(where: { $0.id == selectedElementID }) else {
            return
        }
        page.elements[index].zIndex = (page.elements.map(\.zIndex).min() ?? 0) - 1
    }

    private func nextZIndex() -> Int {
        (page.elements.map(\.zIndex).max() ?? 0) + 1
    }

    @MainActor
    private func importPhoto(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                return
            }
            let filename = try ImageStorage.saveImageData(data)
            let element = ScrapbookElement(
                kind: .photo,
                x: 170,
                y: 210,
                width: 160,
                height: 124,
                rotationDegrees: ScrapbookElement.handmadeRotation(),
                zIndex: nextZIndex(),
                text: "Imported photo",
                style: "image:\(filename)"
            )
            addElement(element)
        } catch {
            assertionFailure("Unable to import photo: \(error.localizedDescription)")
        }
    }
}

private struct EditableElementLayer: View {
    @Binding var element: ScrapbookElement
    @Binding var selectedElementID: UUID?
    @State private var dragStart: CGPoint?
    @State private var scaleStart: CGSize?
    @State private var rotationStart: Double?

    private var isSelected: Bool {
        selectedElementID == element.id
    }

    var body: some View {
        ElementArtwork(element: element, isSelected: isSelected)
            .frame(width: element.width, height: element.height)
            .rotationEffect(.degrees(element.rotationDegrees))
            .position(x: element.x, y: element.y)
            .onTapGesture {
                selectedElementID = element.id
            }
            .simultaneousGesture(dragGesture)
            .simultaneousGesture(scaleGesture)
            .simultaneousGesture(rotationGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStart == nil {
                    dragStart = CGPoint(x: element.x, y: element.y)
                    selectedElementID = element.id
                }

                element.x = (dragStart?.x ?? element.x) + value.translation.width
                element.y = (dragStart?.y ?? element.y) + value.translation.height
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    private var scaleGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if scaleStart == nil {
                    scaleStart = CGSize(width: element.width, height: element.height)
                    selectedElementID = element.id
                }

                let start = scaleStart ?? CGSize(width: element.width, height: element.height)
                element.width = max(34, start.width * value)
                element.height = max(28, start.height * value)
            }
            .onEnded { _ in
                scaleStart = nil
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { value in
                if rotationStart == nil {
                    rotationStart = element.rotationDegrees
                    selectedElementID = element.id
                }

                element.rotationDegrees = (rotationStart ?? element.rotationDegrees) + value.degrees
            }
            .onEnded { _ in
                rotationStart = nil
            }
    }
}

#Preview {
    NavigationStack {
        PageEditorView(
            scrapbookID: Scrapbook.sample.id,
            pageID: Scrapbook.sample.pages[0].id
        )
        .environmentObject(ScrapbookStore.preview)
    }
}
