import SwiftUI

enum ToolbarItemName: Hashable {
    case lock
    case export
    case dockDown
    case dockUp
    case openWindow
}

struct CardControlsView: View {

    @Observable
    class ViewModel {
        var isVisible: Bool
        var locked: Bool = false 

        internal init(isVisible: Bool, locked: Bool = false) {
            self.isVisible = isVisible
            self.locked = locked
        }
    }

    let vm: ViewModel

    var toolbarHandler: ((ToolbarItemName) -> ())?

    #if os(macOS)
    private var middleItems: PreviewToolbarElement<ToolbarItemName> {
        .trio(
            id: "middle",
            .init(id: .dockDown, icon: "inset.filled.bottomhalf.rectangle"),
            .init(id: .dockUp, icon: "inset.filled.tophalf.rectangle"),
            .init(id: .openWindow, icon: "macwindow.on.rectangle"),
        )
    }
    #endif

    #if os(iOS)
    private var middleItems: PreviewToolbarElement<Name> {
        .pair(
            id: "middle",
            .init(id: .dockDown, icon: "inset.filled.bottomhalf.rectangle"),
            .init(id: .dockUp, icon: "inset.filled.tophalf.rectangle"),
        )
    }
    #endif

    var elements: [PreviewToolbarElement<ToolbarItemName>] {
        [
            .item(
                .init(id: .lock, icon: self.vm.locked ? "lock.fill" : "lock"),
            ),
            .spacer,
            self.middleItems,
            .spacer,
            .item(
                .init(id: .export, icon: "square.and.arrow.down"),
            ),
        ]
    }

    func handler(_ name: ToolbarItemName) {
        self.toolbarHandler?(name)
    }

    var body: some View {
        ZStack {
            Color.clear

            PreviewToolbarView(
                elements: self.elements,
                visible: self.vm.isVisible,
                handler: self.handler(_:),
            )
            .animation(.easeInOut(duration: 0.25), value: self.vm.isVisible)
        }
        .ignoresSafeArea()

    }
}
