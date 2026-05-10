import ImageExporter
import SwiftUI

enum ToolbarItemName: Hashable {
    case lock
    case export
    case copy
    case dockDown
    case dockUp
    case openWindow
}

struct CardControlsView: View {

    @Observable
    class ViewModel {
        var isVisible: Bool
        var locked: Bool = false
        var toolbarHandler: ((CardToolbarItemName) -> ())?

        init(isVisible: Bool, locked: Bool = false, toolbarHandler: ((CardToolbarItemName) -> ())? = nil) {
            self.isVisible = isVisible
            self.locked = locked
            self.toolbarHandler = toolbarHandler
        }
    }

    @Bindable var vm: ViewModel

    func handler(_ name: CardToolbarItemName) {
        self.vm.toolbarHandler?(name)
    }

    var body: some View {
        ZStack {
            Color.clear
            CardToolbarView(
                handler: self.handler(_:),
                visible: self.$vm.isVisible,
                locked: self.vm.locked
            )
            .animation(.easeInOut(duration: 0.25), value: self.vm.isVisible)
        }
        .ignoresSafeArea()
    }
}
