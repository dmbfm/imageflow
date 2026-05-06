import Helpers
import SharedModels
import SwiftUI

#if os(macOS)
@MainActor
class ZoomMenuController {

    var coordinator: GlobalCoordinator

    init(_ coordinator: GlobalCoordinator) {
        self.coordinator = coordinator
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu(title: "Zoom")

        let canZoomIn = self.coordinator.canZoomIn()
        let canZoomOut = self.coordinator.canZoomOut()
        let nodeCount = self.coordinator.nodeCount()
        let selectedNodeCount = coordinator.selectedNodeCount()

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
        self.coordinator.perform(userAction: .viewport(.setZoom(1.0)))
    }

    @objc func zoomToFit() {
        self.coordinator.perform(userAction: .viewport(.zoomToFitContent))
    }

    @objc func zoomToFitSel() {
        self.coordinator.perform(userAction: .viewport(.zoomToFitSelection))
    }

    @objc func zoomIn() {
        self.coordinator.perform(userAction: .viewport(.zoomIn))
    }

    @objc func zoomOut() {
        self.coordinator.perform(userAction: .viewport(.zoomOut))
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
