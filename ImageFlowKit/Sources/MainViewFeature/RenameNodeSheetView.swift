import SharedModels
import SwiftUI

struct RenameNodeSheetView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.undoManager) var um
    @State var text: String = ""

    let vm: MainContentViewModel
    let nodeId: UUID?

    func confirm() {
        self.dismiss()
        if let id = self.nodeId {
            let text = self.text
            self.text = ""
            Task {
                self.vm.renameNode(node: id, name: text)
            }
        }
    }

    func cancel() {
        self.text = ""
        self.dismiss()
    }

    var body: some View {
        if let nodeId = self.nodeId {
            InnerView(text: self.$text) {
                self.confirm()
            } onCancel: {
                self.cancel()
            }
            #if os(macOS)
            .onSubmit {
                self.confirm()
            }
            .onExitCommand {
                self.cancel()
            }
            #endif
            .onAppear {
                if let node = self.vm.flow.nodes[nodeId] {
                    self.text = node.name
                }
            }
        } else {
            Text("No node selected!")
                .font(.headline)
        }
    }
}

#if os(macOS)
fileprivate struct InnerView: View {

    @Binding var text: String
    var onOk: (() -> ())?
    var onCancel: (() -> ())?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rename Node")
                .font(.headline)
            TextField("Node Name", text: self.$text)
                #if os(macOS)
            .textContentType(.password)
                #endif
            HStack {
                Spacer()
                Button("Cancel") {
                    self.onCancel?()
                }
                Button("Ok") {
                    self.onOk?()
                }
            }
        }
        .padding()
    }
}
#endif

#if os(iOS)
fileprivate struct InnerView: View {

    @Binding var text: String
    var onOk: (() -> ())?
    var onCancel: (() -> ())?
    @FocusState var focused

    var body: some View {
        NavigationStack {
            Form {
                TextField("Node Name", text: self.$text)
                    .focused(self.$focused)
            }
            .navigationTitle("Rename Node")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK", systemImage: "checkmark") {
                        self.onOk?()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        self.onCancel?()
                    }
                }
            }
            .onAppear { self.focused = true }
        }
        .presentationDetents([.fraction(0.3)])
        .presentationBackgroundInteraction(.disabled)
    }
}
#endif

#Preview {
    @Previewable @State var text: String = "Float Node"
    InnerView(text: $text)
}

#Preview("Modal") {
    @Previewable @State var text: String = "Float Node"
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InnerView(text: $text)
        }
}
