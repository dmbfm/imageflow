private struct AngleControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    @Binding var dragState: DragState

    @State var units: Units = .degrees
    @State var snap: Bool = false

    var range: ClosedRange<Double>? {
        switch self.input.semantics {
        case .float(.angle(.none)):
            nil
        case .float(.angle(.some(let range))):
            if abs(range.span - 2 * .pi) < 0.01 {
                nil
            } else {
                range
            }
        default:
            nil
        }
    }

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

            let newValue =
                if let range, self.dragState == .dragging {
                    change.value.clamped(to: range)
                } else {
                    change.value
                }

            self.vm.submit(
                .input(self.input.index, .float(newValue), change.previous.map(({ .float($0) }))),
                registerUndo: change.commit
            )
        case .degrees:

            let newValue =
                if let range, self.dragState == .dragging {
                    change.value.truncateTo(fractionalDigits: 2).radians.clamped(to: range)
                } else {
                    change.value.truncateTo(fractionalDigits: 2).radians
                }

            self.vm.submit(
                .input(
                    self.input.index,
                    .float(newValue),
                    change.previous.map(({ .float($0.radians) }))
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
                    AngleDial(angle: self.valueInRadians, range: self.range)
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
