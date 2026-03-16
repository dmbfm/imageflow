#if os(iOS)

import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct FloatInputControl: View {
    
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    var doubleValue: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }
    
    var body: some View {
        Group {
            switch input.semantics {
            case .float(.angle(_)):
                AngleControl(input: self.input, vm: self.vm)
            case .float(.range(let range)):
                RangeControl(input: self.input, vm: self.vm, range: range)
            default:
                LabeledContent {
                    RegularControl(input: self.input, vm: self.vm)
                } label: {
                    InputLabel(label: input.label, connected: input.connected)
                }
            }
        }
    }
}

fileprivate struct AngleControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    @State var units: Units = .degrees
    @State var snap: Bool = true
    
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
    
    var sensitivity: Double {
        switch self.units {
        case .radians: 0.016
        case .degrees: 0.4
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
            self.vm.submit(.input(self.input.index, .float(change.value), change.previous.map(({ .float($0)}))), registerUndo: change.commit)
        case .degrees:
            self.vm.submit(.input(self.input.index, .float(change.value.truncateTo(fractionalDigits: 2).radians), change.previous.map(({ .float($0)}))), registerUndo: change.commit)
        }
    }
    
    var body: some View {
        LabeledContent {
                HStack {
                    ZStack(alignment: .leading) {
                        AngleDial(angle: self.valueInRadians)
                        DraggableFloatInput(value: self.value, sensitivity: self.sensitivity, fractionalDigits: 2, onChange: self.onChange(_:))
                        .draggableFloatInputLeadingSpacing(40)
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
                InputLabel(label: input.label, connected: input.connected)
            }
            .onChange(of: self.input.connected, initial: true) {
                if self.input.connected {
                    self.units = .radians
                }
            }
    }
}

fileprivate struct RangeControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    let range: ClosedRange<Double>
    
    var binding: Binding<Double> {
        .init(get: {
            self.vm.nodeInputValue(input.index)?.maybeFloat ?? 0.0
        }, set: { newValue in
            if newValue != self.binding.wrappedValue {
                self.vm.submit(.input(input.index, .float(newValue), nil), registerUndo: false)
            }
        })
    }
    
    func onSliderChange(_ change: SliderEx.Change) {
        log("change: \(change)")
        self.vm.submit(.input(self.input.index, .float(change.value), change.initial.map({ .float($0) })), registerUndo: change.commit)
    }
    
    @State var width: Box<CGFloat> = .init(0.0)
    
    var nonZeroWidth: CGFloat {
        self.width.value == 0.0 ? 1.0 : self.width.value
    }
    
    var sensitivity: Double {
        (self.range.upperBound - self.range.lowerBound) / self.nonZeroWidth
    }
    
    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                InputLabel(label: input.label, connected: input.connected)
                DraggableFloatInput(value: self.value, sensitivity: self.sensitivity, fractionalDigits: 2) { change in
                    self.vm.submit(.input(self.input.index, .float(change.value), change.previous.map({ .float($0) })), registerUndo: change.commit)
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

fileprivate struct RegularControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }
    
    var body: some View {
        DraggableFloatInput(value: self.value, sensitivity: 0.1, fractionalDigits: 2) { change in
            self.vm.submit(.input(self.input.index, .float(change.value), change.previous.map({ .float($0)})), registerUndo: change.commit)
        }
        .disabled(self.input.connected)
    }
}

struct DraggableFloatInput: View {
    let value: Double
    var sensitivity: Double = 0.1
    var fractionalDigits: Int? = 2
    var onChange: (Change) -> ()
    
    @State var initialValue: Double = 0.0
    @State var initialDragValue: Double? = nil
    
    @Environment(\.colorScheme) var cs
    @Environment(\.draggableFloatInputLeadingSpacing) var spacing
    @Environment(\.isEnabled) var enabled
    
    init(value: Double, sensitivity: Double = 0.1, fractionalDigits: Int? = 2, onChange: @escaping (Change) -> Void) {
        self.value = value
        self.sensitivity = sensitivity
        self.onChange = onChange
        self.fractionalDigits = fractionalDigits
    }
    
    
    struct Change {
        var value: Double
        var previous: Double?
        var commit: Bool
    }
    
    func truncatingToFractionalDigits(_ value: Double) -> Double {
        if let fractionalDigits = self.fractionalDigits {
            value.truncateTo(fractionalDigits: fractionalDigits)
        } else {
            value
        }
    }
    
    func onDragChanged(_ translation: CGSize) {
        if self.initialDragValue == nil {
            self.initialDragValue = self.value
        }
        
        if let initial = self.initialDragValue {
            let newValue  = self.truncatingToFractionalDigits(initial + self.sensitivity * translation.width)
            self.onChange(.init(value: newValue, previous: initial, commit: false))
        }
    }
    
    func onDragEnded(_ translation: CGSize) {
        if let initial = self.initialDragValue {
            let newValue = self.truncatingToFractionalDigits(initial + self.sensitivity * translation.width)
            self.onChange(.init(value: newValue, previous: initial, commit: true))
        }
        self.initialDragValue = nil
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: spacing)
            TextFieldEx(
                text: .init(
                    get: {
                        formatter.string(for: self.value) ?? ""
                    },
                    set: { newValue in
                    }
                )
            )
            .textFieldExStyle(.inspectorDefault)
            .textFieldExForegroundColor(self.enabled ? nil : .secondaryLabel)
            .textFieldExDidBeginEditing { text in
                self.initialValue = self.value
            }
            .textFieldExDidChange { text in
            }
            .textFieldExDidEndEditing { text in
                if let number = Double(text) {
                    self.onChange(.init(value: number, previous: self.initialValue, commit: true))
                }
            }
            .textFieldExDragGestureHandler(
                .init(onChange: { self.onDragChanged($0) }, onEnded: { self.onDragEnded($0) })
            )
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .gesture(
            DragGesture()
                .onChanged({ value in self.onDragChanged(value.translation) })
                .onEnded({ value in self.onDragEnded(value.translation) })
        )
    }
}

extension EnvironmentValues {
    @Entry var draggableFloatInputLeadingSpacing: CGFloat = 0.0
}

extension View {
    func draggableFloatInputLeadingSpacing(_ value: CGFloat) -> some View {
        self.environment(\.draggableFloatInputLeadingSpacing, value)
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
        .init(kind: .valueNode(.float))
    ])
}

#endif
