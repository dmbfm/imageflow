#if os(macOS)

import SwiftUI
import AppKit

struct BoolInputView: NSViewRepresentable {

    @Binding var value: Bool

    init(isOn: Binding<Bool>) {
        self._value = isOn
    }

    func makeNSView(context: Context) -> Checkbox {
        let view = Checkbox()
        view.setButtonType(.switch)
        view.isChecked = self.value
        view.title = ""
        view.target = context.coordinator
        view.action = #selector(Coordinator.handle(_:))
        context.coordinator.binding = self.$value
        return view
    }

    func updateNSView(_ view: Checkbox, context: Context) {
        view.isChecked = self.value
        context.coordinator.binding = self.$value
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: Checkbox, context: Context) -> CGSize? {
        nsView.intrinsicContentSize
    }

    class Checkbox: NSButton {
        var isChecked: Bool {
            get { state == .on }
            set { state = newValue ? .on : .off }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    class Coordinator {
        var binding: Binding<Bool>?

        @objc
        func handle(_ checkbox: Checkbox) {
            if let binding = self.binding {
                binding.wrappedValue = checkbox.isChecked
            }
        }
    }
}

#Preview {
    @Previewable @State var checked = false
    VStack {
        BoolInputView(isOn: $checked)
        Text("value: \(checked, default: "")")
    }
    .padding(50)
}

#endif

#if os(iOS)
import SwiftUI
struct BoolInputView: View {

    @Binding var value: Bool

    init(isOn: Binding<Bool>) {
        self._value = isOn
    }

    var body: some View {
        Toggle("", isOn: self.$value)
    }
}
#endif
