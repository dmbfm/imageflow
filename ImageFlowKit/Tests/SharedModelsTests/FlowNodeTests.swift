//
//  FlowNodeTests.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Backend
import Testing
import Values

@testable import SharedModels

@Test("[valueAt:] should return the correct value for a port slot")
func valueAtShouldReturnCorrectValue() async {
    let node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "", index: 0, value: .float(0.5), semantics: .default, connected: false)],
        outputs: []
    )

    #expect(node[valueAt: .input(0)] == .float(0.5))
}

@Test("[valueAt:] should set the correct value for a port slot")
func valueAtShouldSetValue() async {
    var node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "", index: 0, value: .float(0.5), semantics: .default, connected: false)],
        outputs: []
    )

    node[valueAt: .input(0)] = .float(2.0)
    #expect(node[valueAt: .input(0)] == .float(2.0))
}

@Test("[valueTypeAt:] should return the correct value for a port slot")
func valueTypeAtShouldReturnCorrectType() async {
    let node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "", index: 0, value: .float(0.5), semantics: .default, connected: false)],
        outputs: []
    )

    #expect(node[valueTypeAt: .input(0)] == .float)
}

@Test("[labelAt:] should return the correct label for a port slot")
func labelAtShouldReturnCorrectValue() async {
    let node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: false)],
        outputs: []
    )

    #expect(node[labelAt: .input(0)] == "Number")
}

@Test("[connectedAt:] should return the correct value for a port slot")
func connectedAtShouldReturnCorrectValue() async {
    let node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: true)],
        outputs: []
    )

    #expect(node[connectedAt: .input(0)])
}

@Test("[connectedAt:] should set the correct value for a port slot")
func connectedAtShouldSetCorrectValue() async {
    var node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: true)],
        outputs: []
    )

    #expect(node[connectedAt: .input(0)])
    node[connectedAt: .input(0)] = false
    #expect(!node[connectedAt: .input(0)])
}

@Test("slots should return the correct array of PortSlot")
func slotsTest() {
    let node = FlowNode(
        id: .init(),
        name: "",
        kind: .valueNode(.float),
        inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: true)],
        outputs: [.init(label: "", index: 0, type: .float, connected: false)]
    )

    #expect(node.slots == [.input(0), .output(0)])
}

@Test
func testNumConnectedSlots() {
    #expect(
        FlowNode(
            id: .init(),
            name: "",
            kind: .valueNode(.float),
            inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: true)],
            outputs: [.init(label: "", index: 0, type: .float, connected: false)]
        ).numConnectedSlots == 1
    )
    #expect(
        FlowNode(
            id: .init(),
            name: "",
            kind: .valueNode(.float),
            inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: true)],
            outputs: [.init(label: "", index: 0, type: .float, connected: true)]
        ).numConnectedSlots == 2
    )
    #expect(
        FlowNode(
            id: .init(),
            name: "",
            kind: .valueNode(.float),
            inputs: [.init(label: "Number", index: 0, value: .float(0.5), semantics: .default, connected: false)],
            outputs: [.init(label: "", index: 0, type: .float, connected: false)]
        ).numConnectedSlots == 0
    )
}

@Test
func convertTest() {
    let node = FlowNode(kind: .math(.addNode(.float)))
    var converted = node
    #expect(converted.convert(toVariation: .math(.addNode(.int))) == true)
    #expect(converted == .init(id: node.id, kind: .math(.addNode(.int)), name: node.name))
}
