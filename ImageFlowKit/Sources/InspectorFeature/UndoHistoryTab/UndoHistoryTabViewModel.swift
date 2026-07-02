import Combine
import Foundation
import Helpers
import SharedModels

@MainActor
final class UndoHistoryTabViewModel: RxEventHandler {

    @PublishedEx var items: [Item] = []

    @PublishedEx var selected: Int? = nil

    var selectedIndex: Int? {
        self.selected.flatMap { id in
            self.items.firstIndex(where: { $0.id == id })
        }
    }

    var coordinator: GlobalCoordinator

    var cancellables: Set<AnyCancellable> = []

    init(_ coordinator: GlobalCoordinator) {
        self.coordinator = coordinator

        self.coordinator.undoService.publisher.sink { [weak self] state in
            self?.updateItems(state)
        }.store(in: &self.cancellables)
    }

    func updateItems(_ state: UndoService.State) {
        self.items = state.items.map({ item in
            .init(id: item.id, title: item.name, icon: item.icon ?? "arrowshape.turn.up.backward.fill")
        })

        if let selectedItem = state.items[tryGetAt: state.cursor] {
            self.selected = selectedItem.id
        }
    }

    enum Event {
        case select(Int?)
    }

    func receive(event: Event) {
        switch event {
        case .select(let index):
            if let index {
                self.coordinator.undoService.moveUndoCursor(to: index)
            }
        }
    }
}

extension UndoHistoryTabViewModel {
    struct Item: Equatable, Identifiable {
        var id: Int
        var title: String
        var icon: String
    }
}
