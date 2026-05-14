#if os(macOS)
import SwiftUI
import UniformTypeIdentifiers
import SharedModels

struct RecentDocumentsListView: View {

    let items: [RecentDocumentItem]

    var image: NSImage {
        NSWorkspace.shared.icon(for: .imageFlowDocument)
    }

    @State var selection: UUID? = nil

    func openSelected() {
        guard let selected = self.selection else { return }
        guard let item = self.items.first(where: { $0.id == selected }) else { return }
        self.openItem(item)
    }

    func openItem(_ item: RecentDocumentItem) {
        print("openItem: \(item)")
        Task {
            do {
                try await NSDocumentController.shared.openDocument(withContentsOf: item.url, display: true)
            } catch {
                logger.error("error: \(error)")
                self.failed = true
            }
        }
    }

    var body: some View {
        List(selection: self.$selection) {
            ForEach(self.items) { item in
                HStack {
                    Image(nsImage: self.image)
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.path)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .truncationMode(.head)
                    }
                    Spacer()
                }
                .tag(item.id)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture().onEnded({ _ in
                        print("tap?")
                        self.selection = item.id
                    }).simultaneously(
                        with: TapGesture(count: 2).onEnded({ _ in
                            print("tap 2 ?")
                            self.openItem(item)
                        })
                    )
                )
            }
        }
        .onKeyPress(
            .return,
            action: {
                self.openSelected()
                return .handled
            }
        )
        .onChange(of: self.items, initial: true) {
            if self.selection == nil {
                self.selection = self.items.first?.id
            }
        }
        .alert(
            "Failed to open document",
            isPresented: self.$failed,
            actions: {
                Button("OK") {}
            }
        )
    }

    @State var failed: Bool = false
}

#Preview {
    VStack {
        RecentDocumentsListView(items: [
            .init(name: "Untitled", path: "~/Documents"),
            .init(name: "Some name", path: "~/Downloads"),
            .init(name: "Other", path: "/Users/dfortes/Developer/experiments/LayoutTests"),
        ])
    }
}
#endif
