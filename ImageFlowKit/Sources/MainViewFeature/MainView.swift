import FlowDocument
import Helpers
import Logging
import SharedModels
import SwiftUI

public struct MainView: View {

    let documentInfo: DocumentInfo

    @ObservableState var vm: MainViewModel
    @ObservableState var coordinator: GlobalCoordinator

    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.undoManager) var um

    public init(document: FlowDocument, documentInfo: DocumentInfo) {
        self.documentInfo = documentInfo
        let vm = MainViewModel(document: document, documentInfo: documentInfo)
        self._vm = .init(wrappedValue: vm)
        self._coordinator = .init(wrappedValue: .init(GlobalCoordinatorDefaultImpl(flow: vm.flow)))
    }

    func onAppear() {
        #if os(macOS)
        self.dismissWindow(id: WindowID.welcome.rawValue)
        #endif

        self.vm.onAppear()
    }

    func onChangeOfDocumentInfo() {
        self.vm.documentInfoDidChange(self.documentInfo)
    }

    public var body: some View {
        MainContentView(
            flow: self.vm.flow,
            canvas: self.vm.canvas,
            assetStore: self.vm.assetStore,
            coordinator: self.coordinator,
        )
        .onChange(of: self.documentInfo, initial: true) { self.onChangeOfDocumentInfo() }
        .onChange(of: self.um, initial: true) {
            self.vm.undoManager = self.um
            self.coordinator.undoManager = self.um
        }
        .onAppear(perform: self.onAppear)
        .activeViewObject(self.coordinator, key: "main")
    }
}
