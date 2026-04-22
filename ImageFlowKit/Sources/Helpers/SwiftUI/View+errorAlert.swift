import SwiftUI

public struct LocalizedAlertError: LocalizedError {
    var inner: any LocalizedError

    public init(inner: any LocalizedError) {
        self.inner = inner
    }

    public var errorDescription: String? {
        self.inner.errorDescription
    }

    public var failureReason: String? {
        self.inner.failureReason
    }

    public var helpAnchor: String? {
        self.inner.helpAnchor
    }

    public var recoverySuggestion: String? {
        self.inner.recoverySuggestion
    }
}

public struct SimpleMessageLocalizedError: LocalizedError, Sendable {

    public var errorDescription: String?

    public init(_ message: String) {
        self.errorDescription = message
    }
}

extension View {
    public func errorAlert(_ error: Binding<LocalizedAlertError?>) -> some View {
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
