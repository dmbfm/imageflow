import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI
import Values

struct IntegerInputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State private var debouncer: FirstValueDebouncer<Value> = .init(0.25)

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

    func onChange(_ change: IntegerInputView.Change) {
        if change.debounce {
            if change.commit {
                self.debouncer.debounce(
                    value: .int(self.value.wrappedValue),
                    { oldValue in
                        self.vm.submit(.input(self.input.index, .int(change.newValue), oldValue), registerUndo: true)
                    }
                )
            }
            self.vm.submit(
                .input(
                    self.input.index,
                    .int(change.newValue),
                    nil
                ),
                registerUndo: false
            )
        } else {
            self.vm.submit(
                .input(
                    self.input.index,
                    .int(change.newValue),
                    change.oldValue.map({ .int($0) })
                ),
                registerUndo: change.commit
            )
        }
    }

    var value: Binding<Int> {
        .init(
            get: {

                self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
            },
            set: { _ in }
        )
    }

    var body: some View {
        HStack {
            IntegerInputView(value: self.value, onChange: self.onChange(_:))
        }
    }
}
