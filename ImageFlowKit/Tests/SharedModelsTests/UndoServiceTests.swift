import Combine
import Foundation
import Testing

@testable import SharedModels

@Test
func testUndoHistoryInit() {
    let h = UndoHistory()
    #expect(h.items.count == 1)
    #expect(h.items[0].id == 0)
    #expect(h.cursor == 0)
    #expect(h.canUndo == false)
    #expect(h.canRedo == false)
}

@Test
func testUndoHistoryRegisterUndoRedo() {
    var h = UndoHistory()
    h.register(.init(id: 1, name: "Some Action", icon: nil))
    #expect(h.items.count == 2)
    #expect(h.items[0].id == 0)
    #expect(h.items[1].id == 1)
    #expect(h.cursor == 1)
    #expect(h.canUndo == true)
    #expect(h.canRedo == false)

    h.undo()
    #expect(h.items.count == 2)
    #expect(h.items[0].id == 0)
    #expect(h.items[1].id == 1)
    #expect(h.cursor == 0)
    #expect(h.canUndo == false)
    #expect(h.canRedo == true)

    h.redo()
    #expect(h.items.count == 2)
    #expect(h.items[0].id == 0)
    #expect(h.items[1].id == 1)
    #expect(h.cursor == 1)
    #expect(h.canUndo == true)
    #expect(h.canRedo == false)
}

@Test
func testUndoHistoryRegisterAfterUndo() {
    var h = UndoHistory()
    h.register(.init(id: 1, name: "Action 1", icon: nil))
    h.register(.init(id: 2, name: "Action 2", icon: nil))
    h.undo()
    h.undo()
    h.register(.init(id: 3, name: "Action 3", icon: nil))
    #expect(h.items.count == 2)
    #expect(h.items[0].id == 0)
    #expect(h.items[1].id == 3)
    #expect(h.cursor == 1)
    #expect(h.canUndo == true)
    #expect(h.canRedo == false)
}

@Test
@MainActor
func testUndoServiceInit() {
    let um = UndoManager()
    um.groupsByEvent = false
    let s = UndoService(um)
    um.withGroup {
        s.register(withTarget: NSObject(), title: "Some Action", icon: nil, handler: { _ in })
    }
    #expect(s.items.count == 2)
    #expect(s.items[0].id == 0)
    #expect(s.items[1].id == 1)
    #expect(s.cursor == 1)
    #expect(s.canUndo == true)
    #expect(s.canRedo == false)
}

@Test
@MainActor
func testUndoServiceModeUndoCursor() {
    let um = UndoManager()
    um.groupsByEvent = false
    let s = UndoService(um)

    @MainActor
    class Consumer {
        var s: UndoService?

        func doSomething() {
            guard let s = self.s else { return }

            s.beginUndoGrouping()
            s.register(
                withTarget: self,
                title: "Do Something",
                icon: nil,
                handler: { this in
                    this.doSomething()
                }
            )
            s.endUndoGrouping()
        }
    }

    let consumer = Consumer()
    consumer.s = s

    for _ in 0..<25 {
        consumer.doSomething()
    }

    #expect(s.items.count == 26)
    #expect(s.cursor == 25)

    s.moveUndoCursor(to: 0)
    #expect(s.cursor == 0)
    #expect(s.items.count == 26)
    #expect(s.canUndo == false)
    #expect(s.canRedo == true)

    s.moveUndoCursor(to: 10)
    #expect(s.cursor == 10)
    #expect(s.items.count == 26)
    #expect(s.canUndo == true)
    #expect(s.canRedo == true)

    s.undo()
    #expect(s.cursor == 9)
    #expect(s.items.count == 26)
    #expect(s.canUndo == true)
    #expect(s.canRedo == true)

    s.redo()
    #expect(s.cursor == 10)
    #expect(s.items.count == 26)
    #expect(s.canUndo == true)
    #expect(s.canRedo == true)
}
