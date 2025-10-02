import SwiftUI

public extension Binding {
    init(_ base: Binding<Value?>, defaultValue: Value) where Value: Sendable {
        self.init(
            get: {
                base.wrappedValue ?? defaultValue
            },
            set: { newValue in
                base.wrappedValue = newValue
            }
        )
    }

    init(unwrapping base: Binding<Value?>) where Value: Sendable {
        self.init(
            get: {
                base.wrappedValue!
            },
            set: { newValue in
                base.wrappedValue = newValue
            }
        )
    }
}
