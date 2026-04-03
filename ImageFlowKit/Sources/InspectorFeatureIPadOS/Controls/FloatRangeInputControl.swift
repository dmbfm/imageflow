#if os(iOS)

import SwiftUI
import SharedModels
import InspectorFeatureShared
import Logging
import Helpers

struct FloatRangeInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    let range: ClosedRange<Double>

    @State var dragState: DragState = .notDragging

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
        self.vm.submit(
            .input(self.input.index, .float(change.value), change.initial.map({ .float($0) })),
            registerUndo: change.commit
        )
    }

    func onFloatInputChange(_ change: DraggableFloatInput.Change) {

        let newValue =
            if self.dragState == .dragging {
                change.value.clamped(to: self.range)
            } else {
                change.value
            }

        self.vm.submit(
            .input(self.input.index, .float(newValue), change.previous.map({ .float($0) })),
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
                DraggableFloatInput(
                    value: self.value,
                    sensitivity: self.sensitivity,
                    fractionalDigits: 2,
                    dragState: self.$dragState,
                    onChange: self.onFloatInputChange(_:)
                )
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

#endif
