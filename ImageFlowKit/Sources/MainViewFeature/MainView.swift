import FlowDocument
import Helpers
import Logging
import SharedModels
import SwiftUI

public struct MainView: View {

    let documentInfo: DocumentInfo

    @ObservableState var vm: MainViewModel

    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.undoManager) var um

    public init(document: FlowDocument, documentInfo: DocumentInfo) {
        self.documentInfo = documentInfo
        let vm = MainViewModel(document: document, documentInfo: documentInfo)
        self._vm = .init(wrappedValue: vm)
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
            coordinator: self.vm.coordinator,
        )
        .onChange(of: self.documentInfo, initial: true) { self.onChangeOfDocumentInfo() }
        .onChange(of: self.um, initial: true) {
            self.vm.undoManager = self.um
            self.vm.coordinator.undoManager = self.um
        }
        .onAppear(perform: self.onAppear)
        .activeViewObject(self.vm.coordinator, key: "main")
    }
}
