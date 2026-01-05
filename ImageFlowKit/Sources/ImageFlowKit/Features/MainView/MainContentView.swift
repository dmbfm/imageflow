import Backend
import Helpers
import Logging
import Photos
import SwiftUI
import Values

#if os(macOS)
typealias MainContentView = MainContentViewMacOS
#endif

#if os(iOS)
typealias MainContentView = MainContentViewIPadOS
#endif

protocol MainContentViewProtocol: View {
    init(
        flow: Flow,
        canvas: CanvasFeatureState,
        assetStore: AssetStore,
    )
}

extension MainContentView: MainContentViewProtocol {}


struct LocalizedAlertError: LocalizedError {
    var inner: any LocalizedError

    var errorDescription: String? {
        self.inner.errorDescription
    }

    var failureReason: String? {
        self.inner.failureReason
    }

    var helpAnchor: String? {
        self.inner.helpAnchor
    }

    var recoverySuggestion: String? {
        self.inner.recoverySuggestion
    }
}

extension View {
    func errorAlert(_ error: Binding<LocalizedAlertError?>) -> some View {
        self
            .alert(
                isPresented: .constant(error.wrappedValue != nil),
                error: error.wrappedValue,
                actions: {
                    Button("OK") {
                        error.wrappedValue = nil
                    }
                }
            )
    }
}
