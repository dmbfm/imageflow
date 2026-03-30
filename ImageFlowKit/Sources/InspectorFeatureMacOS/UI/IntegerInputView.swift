import Logging
import SwiftUI

struct IntegerInputView: View {

    @Binding var value: Int
    @Binding var dragState: DragState

    var range: ClosedRange<Int>?
    var onChange: (Change) -> ()

    struct Change {
        var newValue: Int
        var oldValue: Int?
        var commit: Bool
        var debounce: Bool = false
    }

    func add(_ amount: Int) {
        let newValue =
            if let range = self.range {
                (self.value + amount).clamped(to: range)
            } else {
                self.value + amount
            }
        self.onChange(.init(newValue: newValue, oldValue: nil, commit: true, debounce: true))
    }

    var doubleValue: Double {
        Double(self.value)
    }

    func onFloatInputChange(_ change: FloatInputView.Change) {
        self.onChange(
            .init(
                newValue: Int(change.newValue.rounded()),
                oldValue: change.oldValue.map({ Int($0.rounded()) }),
                commit: change.commit,
            )
        )
    }

    let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.allowsFloats = false
        return f
    }()

    var body: some View {
        ZStack {

            FloatInputView(value: self.doubleValue, dragState: self.$dragState, onChange: self.onFloatInputChange(_:))
                .floatInputViewNumberFormatter(self.formatter)

            HStack {
                Button {
                    self.add(-1)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .padding(.leading, 6)
                            .padding(.trailing, 6)
                            .frame(height: 24)
                            .contentShape(.rect)
                    }
                    //                        .border(.red)
                }
                .buttonStyle(.plain)
                .buttonRepeatBehavior(.enabled)

                Spacer()

                Button {
                    Task {
                        self.add(1)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .padding(.leading, 6)
                        .padding(.trailing, 6)
                        .frame(height: 24)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .buttonRepeatBehavior(.enabled)
            }
        }
    }
}

#Preview {
    @Previewable @State var value: Int = -10
    VStack {
        // IntegerInputView(value: $value, range: 0...5)
        // IntegerInputView(value: $value)
        // Text("value: \(value)")
    }
    .padding(50)
}
