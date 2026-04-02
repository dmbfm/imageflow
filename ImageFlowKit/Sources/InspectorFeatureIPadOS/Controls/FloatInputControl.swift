#if os(iOS)

import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct FloatInputControl: View {

    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    @State var dragState: DragState = .notDragging

    var doubleValue: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    var statusBarMessage: String {
        switch self.input.semantics {
        case .float(.angle): StatusBarMessage.dragFloatSnap.rawValue
        case .float(.default), .distance, .time, .position2, .position3, .offset, .color, .opaqueColor:
            StatusBarMessage.dragFloat.rawValue
        default: ""
        }
    }

    var body: some View {
        Group {
            switch input.semantics {
            case .float(.angle(_)):
                FloatAngleInputControl(input: self.input, vm: self.vm, dragState: self.$dragState)
                    .dragStateStatusBarMessage(
                        coordinator: self.vm.coordinator,
                        dragState: self.dragState,
                        message: self.statusBarMessage
                    )
            case .float(.range(let range)):
                FloatRangeInputControl(input: self.input, vm: self.vm, range: range)
            default:
                LabeledContent {
                    FloatRegularInputControl(input: self.input, vm: self.vm, dragState: self.$dragState)
                        .dragStateStatusBarMessage(
                            coordinator: self.vm.coordinator,
                            dragState: self.dragState,
                            message: self.statusBarMessage
                        )
                } label: {
                    InputLabel(input: self.input, vm: self.vm)
                }
            }
        }
    }
}

let floatInputFormatter = {
    let f = NumberFormatter()
    f.locale = .init(identifier: "en-US")
    f.minimumIntegerDigits = 1
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 1000
    return f
}()

#Preview("Dot Screen") {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .coreImageFilterNode(.halftoneEffect(.CIDotScreen))),
        .init(kind: .valueNode(.float)),
    ])
}

#Preview("Perspective Rotate") {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .coreImageFilterNode(.geometryAdjustment(.CIPerspectiveRotate))),
        .init(kind: .valueNode(.float)),
    ])
}

#endif
