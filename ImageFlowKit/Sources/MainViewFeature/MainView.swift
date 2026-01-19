import FlowDocument
import Helpers
import Logging
import SharedModels
import SwiftUI

public struct MainView: View {

    let documentInfo: DocumentInfo

    @ObservableState var vm: MainViewModel
    @ObservableState var appMenuCoordinator: AppMenuCoordinator = .init()

    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.undoManager) var um

    public init(document: FlowDocument, documentInfo: DocumentInfo) {
        self.documentInfo = documentInfo
        self._vm = .init(wrappedValue: .init(document: document, documentInfo: documentInfo))
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
        )
        .onChange(of: self.documentInfo, initial: true) { self.onChangeOfDocumentInfo() }
        .onChange(of: self.um, initial: true) {
            self.vm.undoManager = self.um
        }
        .onAppear(perform: self.onAppear)
        .activeViewObject(self.vm.appMenuCoordinator)
    }
}
