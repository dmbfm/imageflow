//
//  InspectorFeatureViewModel.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 24/02/26.
//

import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

@Observable
@MainActor
public class InspectorFeatureViewModel {

    public let flow: Flow
    public let coordinator: GlobalCoordinator
    public var undoManager: UndoManager?

    public var hasNode: Bool {
        self.currentNode != nil
    }

    public var node: FlowNode {
        get {
            self.currentNode ?? .init(kind: .valueNode(.float))
        }
        set {
            if self.currentNode != nil {
                self.currentNode = newValue
            }
        }
    }

    private var currentNode: FlowNode?

    @ObservationIgnored
    private var cancellables: Set<AnyEventEmitterCancellable> = []

    public init(flow: Flow, coordinator: GlobalCoordinator, undoManager: UndoManager?) {
        self.flow = flow
        self.coordinator = coordinator
        // self.coordinator = coordinator
        self.undoManager = undoManager

        self.flow.emitter.on { [weak self] event in
            self?.onFlowEvent(event)
        }.store(in: &self.cancellables)

        self.selectionDidChange()
    }

    func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case .selectionDidChange:
            self.selectionDidChange()
        case .nodesDidChange:
            self.nodesDidChange()
        default:
            break
        }
    }

    func nodesDidChange() {
        guard let current = self.currentNode else { return }

        guard let newValue = self.flow.nodes[current.id] else {
            self.currentNode = nil
            return
        }

        if current != newValue {
            self.currentNode = newValue
        }
    }

    func selectionDidChange() {
        guard let currentNode = self.currentNode else {
            self.setCurrentNodeToSelection()
            return
        }

        guard !self.flow.selection.contains(currentNode.id) else {
            return
        }

        if let currentNode = self.currentNode,
            !currentNode.name.isEmpty,
            self.flow.nodes[currentNode.id]?.name != currentNode.name
        {
            self.submit(.name, registerUndo: true)
        }

        self.setCurrentNodeToSelection()
    }

    func setCurrentNodeToSelection() {
        self.currentNode = self.flow.selection.first.flatMap { id in self.flow.nodes[id] }
    }

    // MARK: - Bindings

    public var nodeName: Binding<String> {
        .init(
            get: {
                self.node.name
            },
            set: {
                self.node.name = $0
            }
        )
    }

    public func nodeInputValueBinding(_ index: Int) -> Binding<Value?> {
        .init(
            get: {
                if let node = self.currentNode, node.inputs.indices.contains(index) {
                    node.inputs[index].value
                } else {
                    nil
                }
            },
            set: { newValue in
                if let newValue {
                    self.currentNode?.inputs[index].value = newValue
                }
            }
        )
    }

    public func nodeInputValue(_ index: Int) -> Value? {
        if let node = self.currentNode, node.inputs.indices.contains(index) {
            node.inputs[index].value
        } else {
            nil
        }
    }

    public enum NodePropertyName {
        case name
        case input(Int, Value, Value?)
    }

    public func submit(_ name: NodePropertyName, registerUndo: Bool) {
        guard let currentNode = self.currentNode else {
            log("submit: currentNode is nil!", level: .warning)
            return
        }

        switch name {
        case .name:
            if currentNode.name.isEmpty {
                self.cancel(.name)
            } else {
                self.flow.setNodeName(
                    id: currentNode.id,
                    newValue: currentNode.name,
                    undoManager: registerUndo ? self.undoManager : nil
                )
            }
        case .input(let index, let value, let oldValue):
            if registerUndo && oldValue == value {
                return
            }
            self.flow.setNodeValue(
                id: currentNode.id,
                index: index,
                oldValue: oldValue,
                newValue: value,
                undoManager: registerUndo ? self.undoManager : nil
            )
        }
    }

    public func cancel(_ name: NodePropertyName) {
        guard let node = self.currentNode, let flowNode = self.flow.nodes[node.id] else {
            return
        }

        switch name {
        case .name:
            if node.name != flowNode.name {
                self.currentNode?.name = flowNode.name
            }

        case .input(_, _, _):
            break
        }
    }
}
