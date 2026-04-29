import Helpers
import SharedModels
import SwiftUI

public struct ZoomMenu: View {
    @ActiveViewObject(GlobalCoordinator.self) var coordinator

    var nodeCount: Int {
        self.coordinator?.flow.nodeCount ?? 0
    }

    var selectionCount: Int {
        self.coordinator?.flow.selectionCount ?? 0
    }

    var hasNoNodes: Bool {
        self.nodeCount == 0
    }

    var hasSelection: Bool {
        self.selectionCount > 0
    }

    public init() {}

    public var body: some View {
        Menu("Zoom") {
            Button("Zoom In", systemImage: .systemIconMagZoomIn) {
                self.coordinator?.perform(userAction: .viewport(.zoomIn))
            }
            .disabled(self.coordinator?.canZoomIn == false)
            .keyboardShortcut("+", modifiers: .command)

            Button("Zoom Out", systemImage: .systemIconMagZoomOut) {
                self.coordinator?.perform(userAction: .viewport(.zoomOut))
            }
            .disabled(self.coordinator?.canZoomOut == false)
            .keyboardShortcut("-", modifiers: .command)

            Button("Actual Size", systemImage: .systemIconMagActualSize) {
                self.coordinator?.perform(userAction: .viewport(.setZoom(1)))
            }
            .keyboardShortcut("0", modifiers: .command)

            Divider()

            Button("Zoom to Fit Content", systemImage: .systemIconMagZoomFit) {
                self.coordinator?.perform(userAction: .viewport(.zoomToFitContent))
            }
            .disabled(self.hasNoNodes)
            .keyboardShortcut("0", modifiers: [.command, .shift])

            Button("Zoom to Fit Selection") {
                self.coordinator?.perform(userAction: .viewport(.zoomToFitSelection))
            }
            .disabled(!self.hasSelection)
            .keyboardShortcut("0", modifiers: [.command, .shift, .option])
        }
    }
}

#if os(macOS)
@MainActor
class ZoomMenuController {
    func makeMenu() -> NSMenu {
        let menu = NSMenu(title: "Zoom")

        let canZoomIn = ImageFlowCoordinator.canZoomIn()
        let canZoomOut = ImageFlowCoordinator.canZoomOut()
        let nodeCount = ImageFlowCoordinator.nodeCount()
        let selectedNodeCount = ImageFlowCoordinator.selectedNodeCount()

        menu.items = [
            .init(
                title: "Zoom In",
                action: canZoomIn ? #selector(Self.zoomIn) : nil,
                target: self,
                keyEquivalent: "+",
                keyEquivalentModifierMask: .command,
                systemSymbolName: .systemIconMagZoomIn,
                accessibilityDescription: "Zoom In",
            ),
            .init(
                title: "Zoom Out",
                action: canZoomOut ? #selector(Self.zoomOut) : nil,
                target: self,
                keyEquivalent: "-",
                keyEquivalentModifierMask: .command,
                systemSymbolName: .systemIconMagZoomOut,
                accessibilityDescription: "Zoom Out",
            ),
            .init(
                title: "Actual Size",
                action: #selector(Self.zoomActualSize),
                target: self,
                keyEquivalent: "0",
                keyEquivalentModifierMask: .command,
                systemSymbolName: .systemIconMagActualSize,
                accessibilityDescription: "Zoom to actual size",
            ),
            .init(
                title: "Zoom to Fit Content",
                action: nodeCount > 0 ? #selector(Self.zoomToFit) : nil,
                target: self,
                keyEquivalent: "0",
                keyEquivalentModifierMask: [.command, .shift],
                systemSymbolName: .systemIconMagZoomFit,
                accessibilityDescription: "Zoom to fit content",
            ),
            .init(
                title: "Zoom to Fit Selection",
                action: selectedNodeCount > 0 ? #selector(Self.zoomToFitSel) : nil,
                target: self,
                keyEquivalent: "0",
                keyEquivalentModifierMask: [.command, .shift, .option],
                systemSymbolName: nil,
                accessibilityDescription: "Zoom to fit selection",
            ),
        ]

        return menu
    }

    @objc func zoomActualSize() {
        ImageFlowCoordinator.perform(userAction: .viewport(.setZoom(1.0)))
    }

    @objc func zoomToFit() {
        ImageFlowCoordinator.perform(userAction: .viewport(.zoomToFitContent))
    }

    @objc func zoomToFitSel() {
        ImageFlowCoordinator.perform(userAction: .viewport(.zoomToFitSelection))
    }

    @objc func zoomIn() {
        ImageFlowCoordinator.perform(userAction: .viewport(.zoomIn))
    }

    @objc func zoomOut() {
        ImageFlowCoordinator.perform(userAction: .viewport(.zoomOut))
    }
}
#endif

#if os(iOS)
import UIKit

// swiftlint:disable function_body_length
@MainActor
func makeZoomUIMenu(_ coordinator: GlobalCoordinator?) -> UIMenu {

    let zoomInDisabled: Bool = coordinator?.canZoomIn == false
    let zoomOutDisabled: Bool = coordinator?.canZoomOut == false
    let zoomToFitContentDisabled: Bool = coordinator?.flow.nodes.isEmpty == true
    let zoomToFitSelectionDisabled: Bool = coordinator?.flow.selection.isEmpty == true

    return .init(
        title: "Zoom",
        children: [
            UIAction(
                title: "Zoom In",
                image: .init(systemName: .systemIconMagZoomIn),
                attributes: zoomInDisabled ? .disabled : [],
                handler: { [weak coordinator] _ in
                    coordinator?.perform(userAction: .viewport(.zoomIn))
                }
            ),
            UIAction(
                title: "Zoom Out",
                image: .init(systemName: .systemIconMagZoomOut),
                attributes: zoomOutDisabled ? .disabled : [],
                handler: { [weak coordinator] _ in
                    coordinator?.perform(userAction: .viewport(.zoomOut))
                }
            ),
            UIAction(
                title: "Actual Size",
                image: .init(systemName: .systemIconMagActualSize),
                attributes: [],
                handler: { [weak coordinator] _ in
                    coordinator?.perform(userAction: .viewport(.setZoom(1)))
                }
            ),

            UIMenu(
                title: "",
                options: [.displayInline],
                children: [
                    UIAction(
                        title: "Zoom to Fit Content",
                        image: .init(systemName: .systemIconMagZoomFit),
                        attributes: zoomToFitContentDisabled ? .disabled : [],
                        handler: { [weak coordinator] _ in
                            coordinator?.perform(userAction: .viewport(.zoomToFitContent))
                        }
                    ),
                    UIAction(
                        title: "Zoom to Fit Selection",
                        attributes: zoomToFitSelectionDisabled ? .disabled : [],
                        handler: { [weak coordinator] _ in
                            coordinator?.perform(userAction: .viewport(.zoomToFitSelection))
                        }
                    ),
                ]
            ),
        ]
    )
}

#endif
