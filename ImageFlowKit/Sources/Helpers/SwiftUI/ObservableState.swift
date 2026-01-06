// Copyright (C) 2025 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI

/// A property wrapper that instantiates an observable object.
///
/// It's like `@State`, except that just like `@StateObject` its
/// initializer accepts an autoclosure so that a single instance of the
/// observable object is created for the whole lifetime of the view.
///
/// For example:
///
/// ```swift
/// @Observable Model {
///     init() { ... }
/// }
///
/// struct MyView: View {
///     @ObservableState var model = Model()
///
///     var body: some View { ... }
/// }
/// ```
@propertyWrapper @MainActor public struct ObservableState<Value: AnyObject & Observable>: DynamicProperty {
    @StateObject private var container = ValueContainer()
    let makeValue: () -> Value

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.makeValue = wrappedValue
    }

    public var wrappedValue: Value {
        container.value ?? makeValue()
    }

    public var projectedValue: Bindable<Value> {
        Bindable(wrappedValue)
    }

    public nonisolated func update() {
        MainActor.assumeIsolated {
            if container.value == nil {
                container.value = makeValue()
            }
        }
    }

    private final class ValueContainer: ObservableObject {
        var value: Value?
    }
}

/// Supplies an observable object to a view’s hierarchy.
///
/// The purpose of `WithBindable` is to make it possible to instantiate
/// observable objects from environment values, while keeping the object
/// alive as long as the view is rendered.
///
/// For example:
///
/// ```swift
/// @Observable Model {
///     var name = ""
///
///     init(service: Service) { ... }
/// }
///
/// struct MyView: View {
///     @Environment(\.service) private var service
///
///     var body: some View {
///         WithBindable {
///             Model(service: service)
///         } content: { $model in
///             TextField("Name", text: $model.name)
///         }
///     }
/// }
/// ```
///
/// `WithBindable` makes sure a single instance of the observable object
/// is created for the whole lifetime of the view. It is thus possible to
/// perform work from the object initializer.
public struct WithBindable<Value: AnyObject & Observable, Content: View>: View {
    @ObservableState var state: Value
    private let content: (Bindable<Value>) -> Content

    /// Supplies a `Bindable` object to a view’s hierarchy.
    ///
    /// For example:
    ///
    /// ```swift
    /// WithBindable {
    ///     Model(...)
    /// } content: { $model in
    ///     TextField($model.name)
    /// }
    /// ```
    public init(
        _ makeValue: @escaping () -> Value,
        @ViewBuilder content: @escaping (Bindable<Value>) -> Content
    ) {
        self._state = ObservableState(wrappedValue: makeValue())
        self.content = content
    }

    public var body: some View {
        content($state)
    }
}

// MARK: - Preview

#if DEBUG
@MainActor @Observable private final class DemoModel {
    static var instanceCount = 0
    var text: String

    init() {
        // Preview crashes if DemoModel is instantiated more than expected.
        // This helps asserting the desired behavior of the preview, which
        // is that model instances are not created as long as the view
        // is rendered.
        precondition(DemoModel.instanceCount < 2)
        DemoModel.instanceCount += 1
        self.text = ""
    }
}

#Preview {
    struct ContainerView: View {
        @State var counter: Int = 1

        var body: some View {
            Form {
                Section {
                    Text(verbatim: "Container body rendered \(counter) times")
                        .contentTransition(.numericText())
                        .animation(.default, value: counter)
                        .monospacedDigit()
                } header: {
                    Text(verbatim: "Container View")
                }

                // ObservableState demo
                Section {
                    DemoView()
                } header: {
                    Text(verbatim: "@ObservableState demo")
                }

                // WithBindable demo
                Section {
                    WithBindable {
                        DemoModel()
                    } content: { $model in
                        TextField("", text: $model.text, prompt: Text(verbatim: "Enter text here"))
                        Text(verbatim: "Text is '\(model.text)'")
                    }
                } header: {
                    Text(verbatim: "WithBindable demo")
                }

                Button {
                    counter += 1
                } label: {
                    Text(verbatim: "Force container body re-evaluation")
                }
            }
            .headerProminence(.increased)
        }
    }

    struct DemoView: View {
        @ObservableState var model = DemoModel()

        var body: some View {
            TextField("", text: $model.text, prompt: Text(verbatim: "Enter text here"))
            Text(verbatim: "Text is '\(model.text)'")
        }
    }

    return ContainerView()
}
#endif
