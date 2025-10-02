import SwiftUI

struct NodePaletteSheetView: View {
    var onTapItem: ((NodePaletteItem) -> ())?
    var topPadding: CGFloat {
        if #available(iOS 26, *) {
            -50
        } else {
            0
        }
    }
    var body: some View {
        NavigationStack {
            NodePaletteListView() { self.onTapItem?($0) }
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
    ZStack {
        Color.clear
        Text("Preview!")
            .font(.largeTitle)
    }
    .sheet(isPresented: .constant(true)) {
        NodePaletteSheetView()
        //            .presentationDetents([.medium, .large])
    }
}
