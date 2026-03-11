import Helpers
import InspectorFeatureShared
import SharedModels
import SwiftUI
import Values

struct IntegerInputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State private var debouncer: FirstValueDebouncer<Value> = .init(0.1)

    var binding: Binding<Int> {
        .init(
            get: {
                self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
            },
            set: { value in
                self.debouncer.debounce(
                    value: .int(self.binding.wrappedValue),
                    { oldValue in
                        self.vm.submit(.input(self.input.index, .int(value), oldValue), registerUndo: true)
                    }
                )

                self.vm.submit(.input(self.input.index, .int(value), nil), registerUndo: false)
            }
        )
    }

    var range: ClosedRange<Int>? {
        switch input.semantics {
        case .integer(let semantics):
            switch semantics {
            case .range(let range):
                range
            default:
                nil
            }
        default:
            nil
        }
    }

    var body: some View {
        HStack {
            IntegerInputView(value: self.binding, range: self.range)
        }
    }
}
