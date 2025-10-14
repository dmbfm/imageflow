import Helpers
import SwiftUI

extension AssetBrowserView {
    struct GridItemInnerView: View {
        let size: CGFloat = 146
        let image: CGImage?
        let name: String?
        var selected: Bool = false
        var failed: Bool = false

        struct Style {
            static let cornerRadiusInner: CGFloat = 6.0
            static let cornerRadiusOuter: CGFloat = 8.0
            static let selectedBorderWidth: CGFloat = 4.0
            static let selectedBorderColor: Color = .blue
        }
        var body: some View {
            VStack {
                ZStack {
                    Color(white: 0.9, opacity: self.image == nil ? 1.0 : 1.0)

                    self.content
                        .padding(10)
                        .frame(width: 110, height: 110)
                        .background {
                            self.backgroundView
                        }
                }
                .contentShape(Rectangle())
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: Style.cornerRadiusOuter))

                self.labelView

            }
            .frame(width: self.size, height: self.size)
        }

        @ViewBuilder
        var content: some View {
            Group {
                if let image = self.image {
                    Group {
                        Image(decorative: image, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Style.cornerRadiusInner))
                    .padding(3)

                } else {
                    Image(systemName: self.failed ? "exclamationmark.triangle.fill" : "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .if(!self.failed) {
                            $0.symbolEffect(.breathe, options: .speed(2))
                        }
                        .if(self.failed) {
                            $0.foregroundStyle(.red)
                        }
                        .padding(30)
                }
            }
        }

        var backgroundView: some View {
            ZStack {
                RoundedRectangle(cornerRadius: Style.cornerRadiusOuter)
                    .fill()
                    .foregroundStyle(self.selected ? Style.selectedBorderColor.opacity(0.32) : .clear)
                RoundedRectangle(cornerRadius: Style.cornerRadiusOuter)
                    .stroke(lineWidth: Style.selectedBorderWidth)
                    .foregroundStyle(self.selected ? Style.selectedBorderColor : .clear)
            }
        }

        var labelView: some View {
            Text(self.name ?? "")
                .help(self.name ?? "")
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

}

#Preview("Loading") {
    @Previewable @State var selected: Bool = false
    @Previewable @State var failed: Bool = false
    @Previewable @State var image: CGImage? = nil

    let gradientImage: CGImage = .verticalGradientImage(
        width: 256,
        height: 256,
        topColor: .init(red: 0.412, green: 0.562, blue: 0.875, alpha: 1.0),
        bottomColor: .init(red: 0.71, green: 0.784, blue: 0.937, alpha: 1.0)
    )!

    VStack {
        AssetBrowserView
            .GridItemInnerView(
                image: image,
                name: "Preview Image",
                selected: selected,
                failed: failed
            )
            .padding(20)
            .frame(width: 200, height: 200)

        Toggle("Selected", isOn: $selected)
            .padding()

        Toggle("Failed", isOn: $failed)
            .padding()

        Button(image == nil ? "Set Image" : "Clear Image") {
            if image == nil {
                image = gradientImage
            } else {
                image = nil
            }
        }

    }
    .padding()
    .background(.white)
}
