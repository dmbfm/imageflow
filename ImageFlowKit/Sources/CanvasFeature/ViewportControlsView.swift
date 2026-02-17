import SwiftUI

struct ViewportControlsView: View {
    var body: some View {
        HStack(alignment: .center) {
            Button {

            } label: {
                Image(systemName: "minus")
                    .frame(height: 30)
                    .frame(width: 20)
                //                    .border(.red)
            }
            .buttonStyle(.borderless)

            Text("100%")
                .frame(width: 54)

            Button {
            } label: {
                Image(systemName: "plus")
                    .frame(height: 30)
                    .frame(width: 20)
                //                     .border(.red)
            }
            .buttonStyle(.borderless)
            //            Divider()
            //                .frame(height: 20)
            //
            //            Button("OK") {}
            //                .buttonStyle(.borderless)

        }
        .frame(height: 36)
        .padding(.horizontal, 12)
        .glassEffect(.regular, in: .capsule)
    }
}

#Preview {
    ZStack(alignment: .bottomLeading) {
        Rectangle()
            .fill(.background)

        ViewportControlsView()
            .offset(x: 10, y: -10)
    }
}
