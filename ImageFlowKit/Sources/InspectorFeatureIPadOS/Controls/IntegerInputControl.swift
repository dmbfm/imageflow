import InspectorFeatureShared
import SwiftUI
import SharedModels

struct IntegerInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    var value: Int {
        self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
    }
    
    var body: some View {
        LabeledContent {
            HStack {
                Text("\(self.value)")
                Stepper("", value: .init(get: {
                    self.value
                }, set: { value in
                    self.vm.submit(.input(self.input.index, .int(value), nil), registerUndo: false)
                }))
                .fixedSize()
            }
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
    }
}

#Preview("Int Value Node") {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .valueNode(.int))
    ])
}
