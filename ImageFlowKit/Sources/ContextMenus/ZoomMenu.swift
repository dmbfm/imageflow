import Helpers
import SharedModels
import SwiftUI

public struct ZoomMenu: View {
    @ActiveViewObject(GlobalCoordinator.self) var coordinator
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
            .disabled(self.coordinator?.flow.nodes.isEmpty ?? true)
            .keyboardShortcut("0", modifiers: [.command, .shift])
            
            Button("Zoom to Fit Selection") {
                self.coordinator?.perform(userAction: .viewport(.zoomToFitSelection))
            }
            .disabled(self.coordinator?.flow.selection.isEmpty ?? true)
            .keyboardShortcut("0", modifiers: [.command, .shift, .option])
        }
    }
}

#if os(iOS)
import UIKit

@MainActor
func makeZoomUIMenu(_ coordinator: GlobalCoordinator?) -> UIMenu {
    
    let zoomInDisabled: Bool = coordinator?.canZoomIn == false
    let zoomOutDisabled: Bool = coordinator?.canZoomOut == false
    let zoomToFitContentDisabled: Bool = coordinator?.flow.nodes.isEmpty == true
    let zoomToFitSelectionDisabled: Bool = coordinator?.flow.selection.isEmpty == true

    return .init(title: "Zoom", children: [
        UIAction(
            title: "Zoom In",
            image: .init(systemName: .systemIconMagZoomIn),
            attributes: zoomInDisabled ? .disabled : [],
            handler: { [weak coordinator] _ in
                coordinator?.perform(userAction: .viewport(.zoomIn))
            }),
        UIAction(
            title: "Zoom Out",
            image: .init(systemName: .systemIconMagZoomOut),
            attributes: zoomOutDisabled ? .disabled : [],
            handler: { [weak coordinator] _ in
                coordinator?.perform(userAction: .viewport(.zoomOut))
            }),
        UIAction(
            title: "Actual Size",
            image: .init(systemName: .systemIconMagActualSize),
            attributes: [],
            handler: { [weak coordinator] _ in
                coordinator?.perform(userAction: .viewport(.setZoom(1)))
            }),
        
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
                    }),
                 UIAction(
                    title: "Zoom to Fit Selection",
                    attributes: zoomToFitSelectionDisabled ? .disabled : [],
                    handler: { [weak coordinator] _ in
                        coordinator?.perform(userAction: .viewport(.zoomToFitSelection))
                    }),
            ]
        ),
    ])
}

#endif
