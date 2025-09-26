#if canImport(AppKit)

import SwiftUI
import AppKit
import Logging
import UniformTypeIdentifiers
import CommonUtils

import enum Models.Action

public struct ImageFlowApp: App {

    // @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: { ImageFlowDocument() }) { configuration in
            MainViewWrapper(configuration.document)
        }
        .defaultWindowPlacement { root, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(.suppressed)

        WelcomeWindow("Image Flow")
            .defaultLaunchBehavior(.presented)
    }
}

struct MainViewWrapper: View {
    let document: ImageFlowDocument
    @State var flow: Flow = .init(.init())
    @State var canvasCenter: Box<CGPoint> = .init(.zero)
    @Environment(\.undoManager) var undoManager

    init(_ document: ImageFlowDocument) {
        self.document = document
    }

    func observeViewport() {
        withObservationTracking(
            {
                _ = self.flow.canvas.viewport
            },
            onChange: {
                Task { @MainActor in
                    self.document.data.withLock { data in
                        data.canvas.viewport = self.flow.canvas.viewport
                    }
                    self.observeViewport()
                }
            }
        )
    }

    func observeNodePositions() {
        withObservationTracking(
            {
                _ = self.flow.canvas.nodePositions
            },
            onChange: {
                Task { @MainActor in
                    self.document.data.withLock { data in
                        data.canvas.nodePositions = self.flow.canvas.nodePositions
                    }
                    self.observeNodePositions()
                }
            }
        )
    }

    func observeNodes() {
        withObservationTracking(
            {
                _ = self.flow.nodeDataStore.nodes
            },
            onChange: {
                Task { @MainActor in
                    self.document.data.withLock { data in
                        data.nodeDataStore.nodes = self.flow.nodeDataStore.nodes
                    }
                    self.observeNodes()
                }
            }
        )
    }

    func observeEdges() {
        withObservationTracking(
            {
                _ = self.flow.nodeDataStore.edges
            },
            onChange: {
                Task { @MainActor in
                    self.document.data.withLock { data in
                        data.nodeDataStore.edges = self.flow.nodeDataStore.edges
                    }
                    self.observeEdges()
                }
            }
        )
    }

    func loadSample() {
    }

    func dispatch(_ action: Action) {
        self.flow.dispatch(action, canvasCenter: self.canvasCenter.value, undoManager: self.undoManager)
    }

    var body: some View {
        Group {
            MainViewMac(
                canvas: flow.canvas,
                nodeDataStore: flow.nodeDataStore,
                nodeSelectionStore: flow.nodeSelectionStore,
                canvasCenter: self.$canvasCenter,
            )
            .environment(\.dispatch, self.dispatch)
        }
        .onAppear {
            let data = Flow.sample.snapshot()
            self.flow.restore(data)
            self.observeViewport()
            self.observeNodePositions()
            self.observeNodes()
            self.observeEdges()
        }
    }
}

#endif  // canImport(AppKit)
