import SwiftUI
import InspectorFeatureShared
import SharedModels

struct InputLabel: View {
    var input: FlowNode.Input
    var vm: InspectorFeatureViewModel
    
    private func handle(_ action: InputLabelInner.Action) {
        switch action {
        case .selectConnected:
            self.vm.flow.select(nodeConnectedToNode: self.vm.node.id, atInputPort: self.input.index)
        case .disconnect:
            self.vm.coordinator.perform(userAction: .disconnect(.init(node: self.vm.node.id, index: self.input.index)))
        }
    }
    
    var body: some View {
        InputLabelInner(label: input.label, connected: input.connected, handle: self.handle(_:))
    }
}

private struct InputLabelInner: View {
    var label: String
    var connected: Bool
    var handle: (Action) -> ()
    
    enum Action {
        case selectConnected
        case disconnect
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
            if connected {
                
                Menu {
                    Button("Select Connected Node") {
                        self.handle(.selectConnected)
                    }
                    Button("Disconnect") {
                        self.handle(.disconnect)
                    }
                } label: {
                    Image(systemName: "arrow.right.circle")
                } primaryAction: {
                    self.handle(.selectConnected)
                }
                .tint(.secondary)
                .frame(width: 20)
                
                
            } else {
                HStack {}.frame(width: 20)
            }
        }
    }
}

#Preview {
    @Previewable @State var connected: Bool = false
    HStack {
        VStack(alignment: .leading) {
            InputLabelInner(label: "Some Input", connected: connected) { action in
                switch action {
                case .disconnect: connected = false
                case .selectConnected: break
                }
            }
            .border(.gray.opacity(0.5))
            Button("Connect") { connected = true }
            Spacer()
        }
        Spacer()
    }
}
