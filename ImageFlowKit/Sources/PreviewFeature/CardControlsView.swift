import ImageExporter
import SharedModels
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
        var isVisible: Bool = true
        var locked: Bool = false
        var toolbarHandler: ((CardToolbarItemName) -> ())?
        var available: Set<PreviewLocation> = []
        var currentLocation: OutputPortLocation? {
            didSet {
                self.didSetCurrentLocation?(self.currentLocation)
            }
        }
        var didSetCurrentLocation: ((OutputPortLocation?) -> ())?

        init(
            isVisible: Bool = true,
            locked: Bool = false,
            toolbarHandler: ((CardToolbarItemName) -> ())? = nil,
            available: Set<PreviewLocation> = [],
            currentLocation: OutputPortLocation? = nil,
            didSetCurrentLocation: ((OutputPortLocation?) -> ())?
        ) {
            self.isVisible = isVisible
            self.locked = locked
            self.toolbarHandler = toolbarHandler
            self.available = available
            self.currentLocation = currentLocation
            self.didSetCurrentLocation = didSetCurrentLocation
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
                visible: self.vm.isVisible,
                locked: self.vm.locked
            )
            .animation(.easeInOut(duration: 0.25), value: self.vm.isVisible)

            CardImagePicker(
                current: self.$vm.currentLocation,
                visible: self.vm.isVisible,
                available: self.vm.available
            )

        }
        .ignoresSafeArea()
    }
}
