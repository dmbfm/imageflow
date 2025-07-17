import SwiftUI
import Values

public struct NodeImageInput: View {
    @Binding var value: ImageValue
    let openAssetBrowser: (() -> ())?

    public init(value: Binding<ImageValue>, openAssetBrowser: (() -> ())? = nil) {
        self._value = value
        self.openAssetBrowser = openAssetBrowser
    }
 
    var label: String {
        if let imageIdentifier = self.value {
            imageIdentifier.uuid.uuidString
        } else {
            "Choose..."
        }
    }

    public var body: some View {
        Button {
            self.openAssetBrowser?()
        } label: {
            Text(self.label)
        }
        #if os(macOS)
            .buttonStyle(.borderless)
        #endif
        .tint(.orange)
        .font(.system(size: 10))
    }
}

#Preview {
    @Previewable @State var value: ImageValue = nil

    VStack {
        NodeImageInput(value: $value) { value = .asset(UUID()) }
            .border(.gray.opacity(0.2))
    }
    .padding(80)
}
