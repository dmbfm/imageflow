import SwiftUI
import SharedModels
import InspectorFeatureShared

struct FloatInputControl: View {
    
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    var binding: Binding<Double> {
        .init(get: {
            self.vm.nodeInputValue(input.index)?.maybeFloat ?? 0.0
        }, set: { newValue in
            self.vm.submit(.input(input.index, .float(newValue), nil), registerUndo: true)
        })
    }
    
    var body: some View {
//        Toggle("", isOn: self.binding)
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [.init(kind: .valueNode(.float))])
}
