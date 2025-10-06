import Helpers
import SwiftUI

extension AssetBrowserView {
    struct GridItemInnerView: View {
        let size: CGFloat = 146
        let image: CGImage?
        let name: String
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
            Text(self.name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }

    }

}

// @MainActor
// let previewImage = Bundle.m


#Preview("Loading") {
    @Previewable @State var selected: Bool = false
    @Previewable @State var failed: Bool = false
    @Previewable @State var image: CGImage? = nil
    // @Previewable @State var image: GridItemInnerView.ImageContent? = nil
    VStack {
        AssetBrowserView
            .GridItemInnerView(
                image: image,
                name: "Preview Image",
                selected: selected,
                failed: failed
            )
        // GridItemInnerView(
        //     image: image,
        //     name: "Example",
        //     selected: selected,
        //     failed: failed
        // )
         .padding(20)
         .frame(width: 200, height: 200)

         Toggle("Selected", isOn: $selected)
             .padding()

         Toggle("Failed", isOn: $failed)
             .padding()

         Button(image == nil ? "Set Image" : "Clear Image") {
             if image == nil {
                 image = makeTestPatternCGImage(width: 110 * 2, height: 110 * 2)
             } else {
                 image = nil
             }
         }

    }
    .padding()
    .background(.white)
}
