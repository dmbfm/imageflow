import SwiftUI
import SharedModels
import InspectorFeatureShared

struct BooleanInputControl: View {
    
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    var binding: Binding<Bool> {
        .init(get: {
            self.vm.nodeInputValue(input.index)?.maybeBool ?? false
        }, set: { newValue in
            self.vm.submit(.input(input.index, .bool(newValue), nil), registerUndo: true)
        })
    }
    
    var body: some View {
        Toggle("", isOn: self.binding)
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [.init(kind: .valueNode(.bool))])
}
