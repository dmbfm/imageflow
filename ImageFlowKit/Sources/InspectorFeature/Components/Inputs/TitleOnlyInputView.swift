import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct TitleOnlyInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        Block {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                Spacer(minLength: 4)
                if !self.input.connected {
                    Text("Connect to a node to set this value")
                        .font(.caption)
                        .foregroundStyle(.secondaryLabel)
                }
            }
        }
    }
}
