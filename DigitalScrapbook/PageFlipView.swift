import SwiftUI

struct PageFlipView: View {
    @EnvironmentObject private var store: ScrapbookStore
    let scrapbookID: UUID
    @State private var currentIndex = 0

    private var scrapbook: Scrapbook? {
        store.scrapbooks.first { $0.id == scrapbookID }
    }

    var body: some View {
        Group {
            if let scrapbook {
                ZStack {
                    Color.scrapbookInk.ignoresSafeArea()

                    VStack(spacing: 18) {
                        header(for: scrapbook)

                        PageCurlView(pages: scrapbook.pages, currentIndex: $currentIndex) { page in
                            PagePreview(
                                page: page,
                                pageNumber: pageNumber(for: page, in: scrapbook),
                                totalPages: scrapbook.pages.count
                            )
                            .padding(.horizontal, 26)
                            .padding(.vertical, 18)
                            .background(Color.scrapbookInk)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 520)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .black.opacity(0.25), radius: 28, y: 20)

                        footer(for: scrapbook)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 22)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.addPage(to: scrapbook.id)
                            currentIndex = max(scrapbook.pages.count, 0)
                        } label: {
                            Label("Add page", systemImage: "plus")
                        }
                    }
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color.scrapbookInk, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            } else {
                ContentUnavailableView("Scrapbook not found", systemImage: "book.closed")
            }
        }
    }

    private func header(for scrapbook: Scrapbook) -> some View {
        VStack(spacing: 8) {
            Text(scrapbook.title)
                .font(.title.bold())
                .foregroundStyle(.white)

            Text("\(scrapbook.pages.count) \(scrapbook.pages.count == 1 ? "page" : "pages")")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(.top, 18)
    }

    private func footer(for scrapbook: Scrapbook) -> some View {
        VStack(spacing: 14) {
            Text("Page \(min(currentIndex + 1, scrapbook.pages.count)) of \(scrapbook.pages.count)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))

            if scrapbook.pages.indices.contains(currentIndex) {
                NavigationLink {
                    PageEditorView(scrapbookID: scrapbook.id, pageID: scrapbook.pages[currentIndex].id)
                } label: {
                    Label("Customize this page", systemImage: "wand.and.stars")
                        .font(.headline)
                        .foregroundStyle(.scrapbookInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white, in: Capsule())
                }
            }
        }
    }

    private func pageNumber(for page: ScrapbookPage, in scrapbook: Scrapbook) -> Int {
        guard let index = scrapbook.pages.firstIndex(where: { $0.id == page.id }) else {
            return 1
        }
        return index + 1
    }
}

struct PagePreview: View {
    let page: ScrapbookPage
    let pageNumber: Int
    let totalPages: Int

    var body: some View {
        ZStack {
            PageBackground(style: page.background)

            ForEach(page.elements.sorted { $0.zIndex < $1.zIndex }) { element in
                ElementArtwork(element: element, isSelected: false)
                    .frame(width: element.width, height: element.height)
                    .rotationEffect(.degrees(element.rotationDegrees))
                    .position(x: element.x, y: element.y)
            }

            VStack {
                Spacer()
                HStack {
                    Text("\(pageNumber)")
                    Spacer()
                    Text("\(totalPages)")
                }
                .font(.caption2.weight(.bold))
                .foregroundStyle(.black.opacity(0.25))
                .padding(18)
            }
        }
        .frame(width: 340, height: 460)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.24), radius: 20, y: 16)
    }
}

struct PageBackground: View {
    let style: PageBackgroundStyle

    var body: some View {
        ZStack {
            baseColor

            switch style {
            case .warmPaper:
                paperNoise
            case .blushStripe:
                stripePattern(color: Color(red: 0.76, green: 0.18, blue: 0.26).opacity(0.42))
            case .blueGrid:
                gridPattern
            case .kraft:
                paperNoise
                    .background(Color(red: 0.69, green: 0.55, blue: 0.36))
            case .mintDots:
                dotPattern
            }
        }
    }

    private var baseColor: some View {
        Group {
            switch style {
            case .warmPaper:
                Color.scrapbookPaper
            case .blushStripe:
                Color(red: 0.91, green: 0.76, blue: 0.75)
            case .blueGrid:
                Color(red: 0.90, green: 0.94, blue: 0.96)
            case .kraft:
                Color(red: 0.69, green: 0.55, blue: 0.36)
            case .mintDots:
                Color(red: 0.82, green: 0.91, blue: 0.84)
            }
        }
    }

    private var paperNoise: some View {
        Canvas { context, size in
            for _ in 0..<180 {
                let point = CGPoint(x: Double.random(in: 0...size.width), y: Double.random(in: 0...size.height))
                let rect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
                context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.035)))
            }
        }
    }

    private func stripePattern(color: Color) -> some View {
        Canvas { context, size in
            let stripeWidth = 28.0
            var x = 0.0
            while x < size.width {
                let rect = CGRect(x: x, y: 0, width: stripeWidth / 2, height: size.height)
                context.fill(Path(rect), with: .color(color))
                x += stripeWidth
            }
        }
    }

    private var gridPattern: some View {
        Canvas { context, size in
            let spacing = 22.0
            var x = 0.0
            var y = 0.0
            var path = Path()

            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }

            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }

            context.stroke(path, with: .color(.blue.opacity(0.14)), lineWidth: 1)
        }
    }

    private var dotPattern: some View {
        Canvas { context, size in
            let spacing = 24.0
            var x = 12.0

            while x < size.width {
                var y = 12.0
                while y < size.height {
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 4, height: 4)),
                        with: .color(.white.opacity(0.35))
                    )
                    y += spacing
                }
                x += spacing
            }
        }
    }
}

struct ElementArtwork: View {
    let element: ScrapbookElement
    let isSelected: Bool

    var body: some View {
        ZStack {
            switch element.kind {
            case .photo:
                photo
            case .text:
                caption
            case .sticker:
                sticker
            case .tape:
                tape
            case .dateNumber:
                dateNumber
            case .paperScrap:
                paperScrap
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.scrapbookCoral, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    .padding(-5)
            }
        }
    }

    private var photo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: .black.opacity(0.20), radius: 8, y: 5)

            if element.style.hasPrefix("image:"), let image = ImageStorage.image(for: String(element.style.dropFirst(6))) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(8)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.76, green: 0.79, blue: 0.83),
                                Color(red: 0.42, green: 0.53, blue: 0.60)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    .padding(8)
            }
        }
    }

    private var caption: some View {
        Text(element.text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(.scrapbookInk)
            .multilineTextAlignment(.center)
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }

    private var sticker: some View {
        Text(element.text.isEmpty ? "★" : element.text)
            .font(.system(size: 42, weight: .black, design: .rounded))
            .foregroundStyle(Color(red: 0.84, green: 0.25, blue: 0.18))
            .shadow(color: .white.opacity(0.95), radius: 1)
    }

    private var tape: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(red: 0.98, green: 0.89, blue: 0.61).opacity(0.78))
            .overlay {
                HStack(spacing: 6) {
                    ForEach(0..<8, id: \.self) { _ in
                        Rectangle()
                            .fill(.white.opacity(0.24))
                            .frame(width: 3)
                    }
                }
            }
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
    }

    private var dateNumber: some View {
        Text(element.text)
            .font(.system(size: 70, weight: .black, design: .rounded))
            .foregroundStyle(.scrapbookBlue)
            .minimumScaleFactor(0.4)
            .shadow(color: .white.opacity(0.9), radius: 1)
    }

    private var paperScrap: some View {
        ZStack {
            if element.style == "redStripe" {
                PageBackground(style: .blushStripe)
            } else {
                Color(red: 0.96, green: 0.91, blue: 0.76)
            }

            Text(element.text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.14), radius: 6, y: 3)
    }
}

#Preview {
    PageFlipView(scrapbookID: Scrapbook.sample.id)
        .environmentObject(ScrapbookStore.preview)
}
