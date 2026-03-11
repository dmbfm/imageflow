import Logging
import SharedModels
import SwiftUI
import InspectorFeatureShared

struct FloatInputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0
    }

    @State var initialValue: Double?

    var range: ClosedRange<Double>? {
        switch self.input.semantics {
        case .float(.range(let range)): range
        case .float(.angle(.none)): 0...360
        case .float(.angle(.some(let range))): (range.lowerBound.degrees)...(range.upperBound.degrees)
        default: nil
        }
    }

    var transformedValue: Double {
        switch self.input.semantics {
        case .float(.angle): self.value.degrees
        default: self.value
        }
    }

    var suffix: String? {
        switch self.input.semantics {
        case .float(.angle): "°"
        default: nil
        }
    }

    func transformValue(_ value: Double) -> Double {
        switch self.input.semantics {
        case .float(.angle): value.radians
        default: value
        }
    }

    var body: some View {
        FloatInputView(
            value: self.transformedValue,
            range: self.range,
            suffix: self.suffix,
            onChange: { change in
                self.vm.submit(
                    .input(
                        self.input.index,
                        .float(self.transformValue(change.newValue)),
                        change.oldValue.map({ .float(self.transformValue($0)) })
                    ),
                    registerUndo: change.commit
                )
            },
        )
    }
}
