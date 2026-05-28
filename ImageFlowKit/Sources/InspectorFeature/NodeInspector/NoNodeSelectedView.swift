import SwiftUI

struct NoNodeSelectedView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No Node Selected")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
