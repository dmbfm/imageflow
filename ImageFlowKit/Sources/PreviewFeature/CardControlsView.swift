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

        init(isVisible: Bool, locked: Bool = false) {
            self.isVisible = isVisible
            self.locked = locked
        }
    }

    @Bindable var vm: ViewModel

    var toolbarHandler: ((CardToolbarItemName) -> ())?

    func handler(_ name: CardToolbarItemName) {
        self.toolbarHandler?(name)
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
