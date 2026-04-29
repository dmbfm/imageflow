import SwiftUI

struct ActionButton: View {
    let text: String
    let icon: String
    let action: () -> ()

    init(_ text: String, icon: String, action: @escaping () -> ()) {
        self.text = text
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            self.action()
        } label: {
            HStack {
                Image(systemName: self.icon)
                    .font(.system(size: 20))
                    .padding(.leading, 8)
                    .foregroundStyle(.secondary)
                Text(self.text)
                    .bold()
                    .fontDesign(.rounded)
                Spacer()
            }
            .frame(height: 40)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
