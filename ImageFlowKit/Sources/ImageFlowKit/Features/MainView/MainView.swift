import Helpers
import Logging
import SwiftUI

struct MainView: View {

    let documentInfo: DocumentInfo

    @ObservableState var vm: MainViewModel

    @Environment(\.dismissWindow) var dismissWindow

    init(document: FlowDocument, documentInfo: DocumentInfo) {
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

    var body: some View {
        MainContentView(
            flow: self.vm.flow,
            canvas: self.vm.canvas,
            assetStore: self.vm.assetStore,
        )
        .onChange(of: self.documentInfo, initial: true) { self.onChangeOfDocumentInfo() }
        .onAppear(perform: self.onAppear)
    }
}
