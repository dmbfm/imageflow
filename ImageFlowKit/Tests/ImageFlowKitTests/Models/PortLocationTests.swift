import Foundation
import Testing
import Values

@testable import ImageFlowKit

@Test
func testSameSideAs() {
    #expect(PortSlot.input(0).sameSideAs(.input(25)))
    #expect(PortSlot.output(10).sameSideAs(.output(25)))
    #expect(!PortSlot.output(0).sameSideAs(.input(0)))
}

@Test
func testCanConnectWith() {
    let id = UUID()
    let a = PortLocation(node: .init(), port: .input(0))
    let b = PortLocation(node: id, port: .output(0))
    let c = PortLocation(node: id, port: .input(0))

    #expect(a.canConnectWith(b))
    #expect(!a.canConnectWith(c))
    #expect(!b.canConnectWith(c))
}
