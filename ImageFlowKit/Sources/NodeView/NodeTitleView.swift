import SwiftUI

public struct NodeTitleView: View, Equatable {
    let title: String
    let subtitle: String
    let icon: String
    let tintColor: Color

    public init(title: String, subtitle: String, icon: String, tintColor: Color) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tintColor = tintColor
    }

    public var body: some View {
        HStack(spacing: 8) {
            IconView(icon: self.icon, tintColor: self.tintColor)
            TitleTextView(title: self.title, subtitle: self.subtitle)
        }
    }
}

fileprivate struct IconView: View, Equatable {
    let icon: String
    let tintColor: Color

    var body: some View {
        Image(systemName: self.icon)
            .foregroundStyle(self.tintColor)
    }
}

fileprivate struct TitleTextView: View, Equatable {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(self.title)
                .font(.system(size: 13, weight: .medium))
            Text(self.subtitle)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NodeTitleView(title: "Add Node", subtitle: "Add Node", icon: "plus", tintColor: .blue)
        .padding(.top, 18)
        .padding(.leading, 8)
        .padding(.bottom, 8)
        .padding(.trailing, 8)
        .nodeCard()
        .padding(50)
}
