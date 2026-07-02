import Combine
import Foundation
import OSLog

@MainActor
public final class UndoService {

    public var undoManager: UndoManager?

    public var publisher: CurrentValueSubject<State, Never>

    public var items: [UndoHistoryItem] {
        self.history.items
    }

    public var cursor: Int {
        self.history.cursor
    }

    public var state: State {
        .init(items: self.items, cursor: self.cursor)
    }

    public var canUndo: Bool {
        self.history.canUndo
    }

    public var canRedo: Bool {
        self.history.canRedo
    }

    public struct State {
        public var items: [UndoHistoryItem]
        public var cursor: Int
    }

    private var currentItem: UndoHistoryItem = .init(id: 1)

    private var history: UndoHistory {
        didSet {
            self.publisher.send(self.state)
        }
    }

    private var cancellables: [AnyCancellable] = []

    public init(_ undoManager: UndoManager?) {
        self.undoManager = undoManager
        let history = UndoHistory()
        self.history = history
        self.publisher = .init(.init(items: history.items, cursor: history.cursor))
        self.setupNotifications()
    }

    public func beginUndoGrouping() {
        guard let um = self.undoManager else {
            logger.warning("No UndoManager!")
            return
        }

        um.beginUndoGrouping()
    }

    public func endUndoGrouping() {
        guard let um = self.undoManager else {
            logger.warning("No UndoManager!")
            return
        }

        um.endUndoGrouping()
    }

    public func setActionName(_ name: String, icon: String? = nil) {
        guard let um = self.undoManager else {
            logger.warning("No UndoManager!")
            return
        }

        um.setActionName(name)
        self.currentItem.name = name
        self.currentItem.icon = icon
    }

    public func undo() {
        guard let um = self.undoManager else {
            logger.warning("No UndoManager!")
            return
        }

        um.undo()
    }

    public func redo() {
        guard let um = self.undoManager else {
            logger.warning("No UndoManager!")
            return
        }

        um.redo()
    }

    public func moveUndoCursor(to index: Int) {
        if index == self.cursor || self.items.isEmpty { return }

        if index < 0 || index >= self.items.count { return }

        guard let um = self.undoManager else { return }

        if index < self.cursor {
            (0..<(self.cursor - index)).forEach({ _ in
                um.undo()
            })
        } else {
            (0..<(index - self.cursor)).forEach({ _ in
                um.redo()
            })
        }
    }

    public func register<TargetType: AnyObject>(
        withTarget target: TargetType,
        title: String?,
        icon: String?,
        handler: @escaping (TargetType) -> ()
    ) {
        guard let um = self.undoManager else {
            logger.warning("No UndoManager!")
            return
        }

        um.registerUndo(withTarget: target, handler: handler)

        if let title {
            um.setActionName(title)
            self.currentItem.name = title
        }

        if let icon {
            self.currentItem.icon = icon
        }
    }

    func setupNotifications() {
        NotificationCenter.default.publisher(for: UndoManager.DidCloseUndoGroupMessage.name).sink {
            [weak self] notification in

            guard let self, let um = notification.object as? UndoManager, self.undoManager == um else {
                logger.warning("Failed to process undo notification")
                return
            }

            if um.groupingLevel == 0 {
                self.history.register(self.currentItem)
                self.currentItem = .init(id: self.currentItem.id + 1)
                // logger.info("\("\(self.undoItems)")")
                // logger.info("\("\(self.redoItems)")")
            }

        }.store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: UndoManager.DidUndoChangeMessage.name).sink {
            [weak self] notification in

            guard let self, let um = notification.object as? UndoManager, self.undoManager == um else {
                logger.warning("Failed to process undo notification!")
                return
            }

            self.history.undo()
            // logger.info("\("\(self.undoItems)")")
            // logger.info("\("\(self.redoItems)")")

        }.store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: UndoManager.DidRedoChangeMessage.name).sink {
            [weak self] notification in

            guard let self, let um = notification.object as? UndoManager, self.undoManager == um else {
                logger.warning("Failed to process undo notification!")
                return
            }

            self.history.redo()
            // logger.info("\("\(self.undoItems)")")
            // logger.info("\("\(self.redoItems)")")
        }.store(in: &self.cancellables)
    }
}
