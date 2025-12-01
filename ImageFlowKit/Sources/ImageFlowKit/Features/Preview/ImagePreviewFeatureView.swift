import Logging
import SwiftUI

struct ImagePreviewFeatureView: View {
    let flow: Flow
    let assetStore: AssetStore
    @State var vm: ImagePreviewFeatureViewModel

    internal init(flow: Flow, assetStore: AssetStore) {
        self.flow = flow
        self.assetStore = assetStore
        self._vm = .init(wrappedValue: .init(flow: flow, assetStore: assetStore))
    }

    var body: some View {

        @Bindable var vm = self.vm 

        ImagePreviewView(
            self.vm.previewState,
            initialSize: .medium,
            isLocked: $vm.isLocked
        )
    }
}
