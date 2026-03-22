#if os(iOS)

import InspectorFeatureShared
import SharedModels
import SwiftUI
import Values
import Design

struct VectorInputControl: View {

    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    @Environment(\.colorScheme) var cs

    var dim: Int {
        switch input.value.type {
        case .vector2: 2
        case .vector3: 3
        case .vector4: 4
        default: 0
        }
    }

    func label(_ index: Int) -> String {
        switch index {
        case 0: "x"
        case 1: "y"
        case 2: "z"
        case 3: "w"
        default: ""
        }
    }

    var value: Value? {
        self.vm.nodeInputValue(self.input.index)
    }

    func value(_ index: Int) -> Double {
        self.value?.vector(index: index) ?? 0.0
    }

    func value(updatingIndex index: Int, _ value: Double) -> Value? {
        self.value?.vector(settingIndex: index, to: value) ?? nil
    }

    func onChange(_ index: Int, _ change: DraggableFloatInput.Change) {
        if let value = self.value(updatingIndex: index, change.value) {
            let previous = change.previous.flatMap({ self.value(updatingIndex: index, $0) })
            self.vm.submit(.input(self.input.index, value, previous), registerUndo: change.commit)
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            InputLabel(input: self.input, vm: self.vm)
            VStack {
                ForEach(0..<self.dim, id: \.self) { index in
                    HStack {
                        Text("\(self.label(index))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        DraggableFloatInput(value: self.value(index), onChange: { self.onChange(index, $0) })
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background {
                        Colors.inspectorControlBgIOS.color
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

extension Value {
    func vector(index: Int) -> Double {
        switch self {
        case .vector2:
            self.vector2[index]
        case .vector3:
            self.vector3[index]
        case .vector4:
            self.vector4[index]
        default:
            0.0
        }
    }

    func vector(settingIndex index: Int, to value: Double) -> Value {
        switch self {
        case .vector2:
            var v = self.vector2
            v[index] = value
            return .vector2(v)
        case .vector3:
            var v = self.vector3
            v[index] = value
            return .vector3(v)
        case .vector4:
            var v = self.vector4
            v[index] = value
            return .vector4(v)
        default:
            return self
        }
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .splitValue(.vector2)),
        .init(kind: .splitValue(.vector3)),
        .init(kind: .splitValue(.vector4)),
    ])
}

#endif
