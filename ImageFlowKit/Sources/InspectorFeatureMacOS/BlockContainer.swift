import SwiftUI

struct BlockContainer<Content: View>: View {
    var content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            HStack {
                self.content
            }
            .padding(.leading, 6)
            .padding(.trailing, 6)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct InspectorBlock<Content: View>: View {
    var content: Content
    var title: String

    @State var expanded: Bool = true

    init(_ title: String, @ViewBuilder _ content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var chevronIcon: String {
        self.expanded ? "chevron.down" : "chevron.right"
    }

    func onTapHeader() {
        self.expanded.toggle()
    }

    var body: some View {
        BlockContainer {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: self.chevronIcon)
                            .bold()
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 10))
                            .frame(width: 10)
                        Text(self.title)
                            .bold()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.onTapHeader()
                    }
                    Spacer()
                }

                if self.expanded {
                    self.content
                        .padding(.leading, 16)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
