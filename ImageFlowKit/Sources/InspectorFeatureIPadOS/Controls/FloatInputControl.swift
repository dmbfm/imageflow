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
    
    func onChangeOfDragState() {
        if self.dragState == .dragging {
            let message: String? = switch self.input.semantics {
            case .float(.angle): StatusBarMessage.dragFloatSnap.rawValue
            case .float(.default), .distance, .time, .position2, .position3, .offset, .color, .opaqueColor: StatusBarMessage.dragFloat.rawValue
            default: nil
            }
            self.vm.coordinator.statusBar(message)
        } else {
            self.vm.coordinator.statusBar(nil)
        }
    }

    var body: some View {
        Group {
            switch input.semantics {
            case .float(.angle(_)):
                AngleControl(input: self.input, vm: self.vm, dragState: self.$dragState)
            case .float(.range(let range)):
                RangeControl(input: self.input, vm: self.vm, range: range)
            default:
                LabeledContent {
                    RegularControl(input: self.input, vm: self.vm, dragState: self.$dragState)
                } label: {
                    InputLabel(input: self.input, vm: self.vm)
                }
            }
        }
        .onChange(of: self.dragState, initial: true, self.onChangeOfDragState)
    }
}

private struct AngleControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    @Binding var dragState: DragState

    @State var units: Units = .degrees
    @State var snap: Bool = false

    var value: Double {
        switch self.units {
        case .radians:
            self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
        case .degrees:
            self.vm.nodeInputValue(self.input.index)?.maybeFloat?.degrees ?? 0.0
        }
    }

    enum Units: Equatable {
        case radians
        case degrees

        var pickerLabel: String {
            switch self {
            case .degrees: "Degrees"
            case .radians: "Radians"
            }
        }

        var label: String {
            switch self {
            case .degrees: "deg"
            case .radians: "rad"
            }
        }
    }

    var sensitivity: DraggableFloatInput.Sensitivity {
        switch self.units {
        case .radians:
                .init(normal: 1.0.radians, slow: 0.025.radians, fast: 10.0.radians)
        case .degrees:
                .init(normal: 1.0, slow: 0.025, fast: 10.0)
        }
    }

    var valueInRadians: Double {
        switch self.units {
        case .degrees: self.value.radians
        case .radians: self.value
        }
    }

    func onChange(_ change: DraggableFloatInput.Change) {
        switch self.units {
        case .radians:
            self.vm.submit(
                .input(self.input.index, .float(change.value), change.previous.map(({ .float($0) }))),
                registerUndo: change.commit
            )
        case .degrees:
            self.vm.submit(
                .input(
                    self.input.index,
                    .float(change.value.truncateTo(fractionalDigits: 2).radians),
                    change.previous.map(({ .float($0) }))
                ),
                registerUndo: change.commit
            )
        }
    }

    var snapping: DraggableFloatInput.Snapping {
            if self.units == .degrees {
                .init(enabled: self.snap, increment: 45.0, tolerance: 10.0)
            } else {
                .init(enabled: self.snap, increment: 45.0.radians, tolerance: 10.0.radians)
            }
    }

    var body: some View {
        LabeledContent {
            HStack {
                ZStack(alignment: .leading) {
                    AngleDial(angle: self.valueInRadians)
                    DraggableFloatInput(
                        value: self.value,
                        sensitivity: self.sensitivity,
                        fractionalDigits: 2,
                        dragState: self.$dragState,
                        onChange: self.onChange(_:)
                    )
                    .draggableFloatInputLeadingSpacing(40)
                    .draggableFloatInputSnapping(self.snapping)
                }
                Menu {
                    Picker("", selection: self.$units) {
                        Text("Degrees").tag(Units.degrees)
                        Text("Radians").tag(Units.radians)
                    }
                    Divider()
                    Toggle("Snap angles", isOn: self.$snap)
                } label: {
                    Text(self.units.label)
                }
                .buttonStyle(.borderless)
                .compositingGroup()
            }
            .disabled(self.input.connected)
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
        .onChange(of: self.input.connected, initial: true) {
            if self.input.connected {
                self.units = .radians
            }
        }
    }
}

private struct RangeControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    let range: ClosedRange<Double>

    var binding: Binding<Double> {
        .init(
            get: {
                self.vm.nodeInputValue(input.index)?.maybeFloat ?? 0.0
            },
            set: { newValue in
                if newValue != self.binding.wrappedValue {
                    self.vm.submit(.input(input.index, .float(newValue), nil), registerUndo: false)
                }
            }
        )
    }

    func onSliderChange(_ change: SliderEx.Change) {
        log("change: \(change)")
        self.vm.submit(
            .input(self.input.index, .float(change.value), change.initial.map({ .float($0) })),
            registerUndo: change.commit
        )
    }

    @State var width: Box<CGFloat> = .init(0.0)

    var nonZeroWidth: CGFloat {
        self.width.value == 0.0 ? 1.0 : self.width.value
    }

    var sensitivity: DraggableFloatInput.Sensitivity {
        let s = (self.range.upperBound - self.range.lowerBound) / self.nonZeroWidth
        return .init(normal: s, slow: s, fast: s)
    }

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                InputLabel(input: self.input, vm: self.vm)
                DraggableFloatInput(value: self.value, sensitivity: self.sensitivity, fractionalDigits: 2) { change in
                    self.vm.submit(
                        .input(self.input.index, .float(change.value), change.previous.map({ .float($0) })),
                        registerUndo: change.commit
                    )
                }
                .disabled(self.input.connected)
            }
            SliderEx(value: self.binding, range: self.range)
                .sliderExThumbVisibility(.hidden)
                .sliderExBindingMode(.callback)
                .sliderExFractionalDigits(2)
                .sliderExOnChange(self.onSliderChange(_:))
                .tint(.gray)
                .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: { self.width.value = $0 })
                .disabled(self.input.connected)
        }
    }
}

private struct RegularControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    @Binding var dragState: DragState

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    var body: some View {
        DraggableFloatInput(value: self.value, fractionalDigits: 2, dragState: self.$dragState) { change in
            self.vm.submit(
                .input(self.input.index, .float(change.value), change.previous.map({ .float($0) })),
                registerUndo: change.commit
            )
        }
        .disabled(self.input.connected)
    }
}

let formatter = {
    let f = NumberFormatter()
    f.locale = .init(identifier: "en-US")
    f.minimumIntegerDigits = 1
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 1000
    return f
}()

#Preview {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .coreImageFilterNode(.halftoneEffect(.CIDotScreen))),
        .init(kind: .valueNode(.float)),
    ])
}

#endif
