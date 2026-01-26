import SharedModels
import SwiftUI

public struct NodePaletteSheetView: View {
    let focus: FocusState<Focus?>.Binding
    var onTapItem: ((NodePaletteItem) -> ())?
    let topPadding: CGFloat = -50
    let port: TypedPortLocation?

    public init(
        port: TypedPortLocation?,
        focus: FocusState<Focus?>.Binding,
        onTapItem: ((NodePaletteItem) -> Void)? = nil
    ) {
        self.onTapItem = onTapItem
        self.focus = focus
        self.port = port
    }

    public var body: some View {
        NavigationStack {
            NodePaletteListView(focusBinding: self.focus, port: self.port) { self.onTapItem?($0) }
                .navigationBarBackButtonHidden()
                .navigationTitle("Add Node")
                #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
                #endif
        }
        .padding(.top, self.topPadding)
    }
}

#Preview {
    @Previewable @FocusState var focus: Focus?
    ZStack {
        Color.clear
        Text("Preview!")
            .font(.largeTitle)
    }
    .sheet(isPresented: .constant(true)) {
        NodePaletteSheetView(port: nil, focus: $focus)
        //            .presentationDetents([.medium, .large])
    }
}
