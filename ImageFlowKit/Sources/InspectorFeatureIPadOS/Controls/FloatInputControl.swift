import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct FloatInputControl: View {

    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    @Environment(\.colorScheme) var cs

    var binding: Binding<Double> {
        .init(
            get: {
                self.vm.nodeInputValue(input.index)?.maybeFloat ?? 0.0
            },
            set: { newValue in
                if let current = self.vm.nodeInputValue(input.index)?.maybeFloat, current != newValue {
                    self.vm.submit(.input(input.index, .float(newValue), nil), registerUndo: false)
                }
            }
        )
    }

    @State var initialValue: Double = 0.0
    @State var initialDragValue: Double? = nil
    @State var sensitivity: CGFloat = 0.1

    func onDragChanged(_ translation: CGSize) {
        if self.initialDragValue == nil {
            self.initialDragValue = self.binding.wrappedValue
        }

        if let initial = self.initialDragValue {
            self.binding.wrappedValue = (initial + self.sensitivity * translation.width).truncateTo(fractionalDigits: 2)
        }
    }

    func onDragEnded(_ translation: CGSize) {
        if let initial = self.initialDragValue {
            let value = (initial + self.sensitivity * translation.width).truncateTo(fractionalDigits: 2)
            self.vm.submit(.input(self.input.index, .float(value), .float(initial)), registerUndo: true)
        }
        self.initialDragValue = nil
    }

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            TextFieldEx(
                text: .init(
                    get: {
                        formatter.string(for: self.binding.wrappedValue) ?? ""
                    },
                    set: { newValue in
                    }
                )
            )
            .textFieldExStyle(.inspectorDefault)
            .textFieldExDidBeginEditing { text in
                self.initialValue = self.binding.wrappedValue
            }
            .textFieldExDidChange { text in
            }
            .textFieldExDidEndEditing { text in
                if let number = Double(text) {
                    self.vm.submit(
                        .input(self.input.index, .float(number), .float(self.initialValue)),
                        registerUndo: true
                    )
                }
            }
            .textFieldExDragGestureHandler(
                .init(onChange: { self.onDragChanged($0) }, onEnded: { self.onDragEnded($0) })
            )
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .gesture(
            DragGesture()
                .onChanged({ value in self.onDragChanged(value.translation) })
                .onEnded({ value in self.onDragEnded(value.translation) })
        )
    }
}

let formatter = {
    let f = NumberFormatter()
    f.locale = .init(identifier: "en-US")
    f.minimumIntegerDigits = 1
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 1000
    return f
}()

#Preview {
    InspectorFeatureView.Preview(nodes: [.init(kind: .valueNode(.float))])
}
