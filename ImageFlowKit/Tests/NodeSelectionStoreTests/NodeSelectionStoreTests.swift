import Foundation
import NodeSelectionStore
import Testing

@Test func emptySelection() {
    let s = NodeSelectionStore()
    #expect(s.selection.isEmpty)
}

@Test func selectSingleNode() {
    var s = NodeSelectionStore()
    let id = UUID()
    s.select(node: id)
    #expect(s.selection.count == 1)
    #expect(s.selection.first == id)
}

@Test func selectManyNodes() {
    var s = NodeSelectionStore()
    let ids: [UUID] = (0...20).map { _ in UUID() }
    s.select(nodes: ids)
    #expect(s.selection.count == ids.count)
    for id in ids {
        #expect(s.selection.contains(id))
    }
}

@Test func selectUnion() {
    let initialIds: [UUID] = (0...20).map { _ in UUID() }
    var s = NodeSelectionStore(selection: Set(initialIds))
    let ids: [UUID] = (0...20).map { _ in UUID() }
    s.select(nodes: ids, mode: .union)
    #expect(s.selection.count == ids.count + initialIds.count)
    for id in Set(ids).union(Set(initialIds)) {
        #expect(s.selection.contains(id))
    }
}

@Test func selectReplace() {
    let initialIds: [UUID] = (0...20).map { _ in UUID() }
    var s = NodeSelectionStore(selection: Set(initialIds))
    let ids: [UUID] = (0...20).map { _ in UUID() }
    s.select(nodes: ids, mode: .replace)
    #expect(s.selection.count == ids.count)
    for id in ids {
        #expect(s.selection.contains(id))
    }
    for id in initialIds {
        #expect(!s.selection.contains(id))
    }
}

@Test func deselectNodes() {
    var s = NodeSelectionStore()
    let a: [UUID] = (0...20).map { _ in UUID() }
    let b: [UUID] = (0...20).map { _ in UUID() }

    s.select(nodes: a)
    s.select(nodes: b, mode: .union)
    s.deselectNodes(nodes: Set(a))

    #expect(s.selection.count == b.count)
    for id in a {
        #expect(!s.selection.contains(id))
    }
    for id in b {
        #expect(s.selection.contains(id))
    }
}
