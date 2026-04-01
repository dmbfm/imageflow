import InspectorFeatureShared
import SharedModels
import SwiftUI

extension Double {
    func degToUnit(_ unit: AngleInputControlView.Unit) -> Self {
        switch unit {
        case .degrees: self
        case .radians: self.radians
        }
    }
    func radToUnit(_ unit: AngleInputControlView.Unit) -> Self {
        switch unit {
        case .degrees: self.degrees
        case .radians: self
        }
    }
}

struct AngleInputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State var unit: Unit = .degrees
    @State var snapping: Bool = false
    @State var dragState: DragState = .notDragging

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    var transformedValue: Double {
        switch self.unit {
        case .degrees: self.value.degrees
        case .radians: self.value
        }
    }

    var range: ClosedRange<Double>? {
        switch self.input.semantics {
        case .float(.angle(.none)): -180.degToUnit(self.unit)...180.degToUnit(self.unit)
        case .float(.angle(let range)):
            range.map({ $0.lowerBound.radToUnit(self.unit)...$0.upperBound.radToUnit(self.unit) })
        default: nil
        }
    }

    var suffix: String {
        switch self.unit {
        case .degrees: "°"
        case .radians: " rad"
        }

    }

    enum Unit {
        case degrees
        case radians

        func radians(_ value: Double) -> Double {
            switch self {
            case .radians: value
            case .degrees: value.radians
            }
        }
    }

    func onChange(_ change: FloatInputView.Change) {
        func transform(_ value: Double) -> Double {
            #if os(macOS)
            let snap = self.snapping || (NSApp.keyWindow?.currentEvent?.modifierFlags.contains(.command) ?? false)
            #else
            let snap = self.snapping
            #endif
            if snap {
                return self.unit.radians(value)
                    .snapping(toIncrements: 45.0.radians, epsilon: change.shiftDown ? 3.radians : 12.radians)
            } else {
                return self.unit.radians(value)
            }
        }

        self.vm.submit(
            .input(
                self.input.index,
                .float(transform(change.newValue)),
                change.oldValue.map({ .float(self.unit.radians($0)) })
            ),
            registerUndo: change.commit
        )
    }

    var body: some View {

        if !self.input.connected {
            Menu {
                self.menuContent
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    InspectorPropertyLabel(label: self.input.label)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .controlSize(.small)
                }
                .contentShape(Rectangle())
            }
            .menuStyle(.button)
            .menuIndicator(.visible)
            .buttonStyle(.plain)
        } else {
            InspectorPropertyLabel(label: self.input.label)
        }
        AngleDial(angle: self.value)
            .angleDialRadius(10)
            .angleDialThumbRadius(2)
            .angleDialDisabledBehavior(.nothing)
            .padding(.trailing, 2)

        HStack(alignment: .center, spacing: 0) {
            FloatInputView(
                value: self.transformedValue,
                range: self.range,
                step: 0.01,
                suffix: self.suffix,
                dragState: self.$dragState,
                onChange: self.onChange(_:)
            )
            .dragStateStatusBarMessage(
                coordinator: self.vm.coordinator,
                dragState: self.dragState,
                message: StatusBarMessage.dragFloatSnap.rawValue
            )

            Spacer(minLength: 0)
        }

        InputConnectedNodeButton(vm: self.vm, input: input)
            .onChange(of: self.input.connected, initial: true) {
                if self.input.connected {
                    self.unit = .radians
                }
            }
    }

    @ViewBuilder
    var menuContent: some View {
        Picker("Units", selection: self.$unit) {
            Text("Degrees").tag(Unit.degrees)
            Text("Radians").tag(Unit.radians)
        }
        .pickerStyle(.inline)

        Divider()

        Toggle("Snapping", isOn: self.$snapping)
    }
}
