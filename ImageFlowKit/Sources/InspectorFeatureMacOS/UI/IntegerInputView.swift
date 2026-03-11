import Logging
import SwiftUI

struct IntegerInputView: View {

    @Binding var value: Int

    var range: ClosedRange<Int>?

    func add(_ amount: Int) {
        self.value =
            if let range = self.range {
                (self.value + amount).clamped(to: range)
            } else {
                self.value + amount
            }
        log("\(amount), \(self.value)")
    }

    var body: some View {
        ZStack {
            TextFieldEx(value: self.$value, format: .number)
                .inspector(horizontalPadding: 24)
            //                .controlSize(.extraLarge)
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
                    self.add(1)
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
        IntegerInputView(value: $value, range: 0...5)
        IntegerInputView(value: $value)
        Text("value: \(value)")
    }
    .padding(50)
}
