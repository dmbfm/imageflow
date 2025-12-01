import Logging
import SwiftUI

struct TouchImagePreviewFeatureView: View {
    let flow: Flow
    let assetStore: AssetStore

    @State var vm: ImagePreviewFeatureViewModel

    @Namespace var ns

    internal init(flow: Flow, assetStore: AssetStore) {
        self.flow = flow
        self.assetStore = assetStore
        self._vm = .init(wrappedValue: .init(flow: flow, assetStore: assetStore))
    }

    var body: some View {

        @Bindable var vm = self.vm 

        TouchImagePreviewView(
            state: self.vm.previewState,
            isLocked: $vm.isLocked,
        )
    }
}
