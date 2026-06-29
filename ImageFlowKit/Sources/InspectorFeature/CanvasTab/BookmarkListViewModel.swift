import Combine
import Helpers
import SharedModels
import XKit

@MainActor
final class BookmarkListViewModel: Rx, RxEventHandler {

    @PublishedEx var items: [Item] = []
    @PublishedEx var selectedIndex: Int? = nil

    var cancellables: Set<AnyCancellable> = []
    var context: InspectorContext

    init(_ context: InspectorContext) {
        self.context = context
        self.context.coordinator?.canvasBookmarksPublisher.map({ .bookmarks($0) }).sendEvents(to: self)
        self.context.coordinator?.canvasViewportPublisher
            .throttle(for: 0.25, scheduler: RunLoop.main, latest: true)
            .map({ .viewport($0) })
            .sendEvents(to: self)
    }

    func delete(_ id: UUID) {
        self.context.coordinator?.perform(userAction: .removeBookmark(id))
    }

    func rename(_ id: UUID, _ name: String) {
        self.context.coordinator?.perform(userAction: .renameBookmark(id, name))
    }

    enum Event {
        case selectedIndex(Int?)
        case viewport(CanvasViewportModel)
        case bookmarks(CanvasBookmarks)
    }

    func receive(event: Event) {
        switch event {
        case .selectedIndex(let index):
            self.onSelectedIndexEvent(index)
        case .viewport(let viewport):
            self.onViewportEvent(viewport)
        case .bookmarks(let bookmarks):
            self.onBookmarksEvent(bookmarks)
        }
    }

    func onBookmarksEvent(_ bookmarks: CanvasBookmarks) {
        self.items = bookmarks.bookmarks.map({
            Item(
                id: $0.id,
                name: $0.name,
                position: $0.viewport.origin,
                scale: $0.viewport.scale
            )
        })
    }

    func onSelectedIndexEvent(_ index: Int?) {
        if let coordinator = self.context.coordinator {
            if index != self.selectedIndex {
                if let index, let item = self.items[tryGetAt: index] {
                    coordinator.perform(
                        userAction: .setCanvasViewPort(
                            .init(
                                origin: item.position,
                                scale: item.scale
                            )
                        )
                    )
                }
                self.selectedIndex = index
            }
        }
    }

    func onViewportEvent(_ viewport: CanvasViewportModel) {
        if let current = self.selectedIndex, let item = self.items[tryGetAt: current],
            item.equalViewport(viewport)
        {
            return
        }

        for (index, item) in self.items.enumerated() {
            if viewport.origin.x == item.position.x
                && viewport.origin.y == item.position.y
                && viewport.scale == item.scale
            {
                self.selectedIndex = index
                return
            }
        }

        self.selectedIndex = nil
    }
}

struct Item {
    var id: UUID
    var name: String
    var position: CGPoint
    var scale: CGFloat

    func equalViewport(_ viewport: CanvasViewportModel) -> Bool {
        viewport.origin.x == self.position.x
            && viewport.origin.y == self.position.y
            && viewport.scale == self.scale
    }
}
