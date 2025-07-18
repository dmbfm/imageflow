import SwiftUI
import Values

public struct NodeColor3Input: View {

    @Binding var value: Color3

    var binding: Binding<CGColor> {
        .init {
            .init(srgbRed: value.red, green: value.green, blue: value.blue, alpha: 1.0)
        } set: { color in
            let c = color.converted(to: .init(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
            let comps = c.components!
            self.value = .init(red: comps[0], green: comps[1], blue: comps[2])
        }
    }

    public var body: some View {
        ColorPicker("", selection: self.binding, supportsOpacity: false)
            .controlSize(.small)
            #if os(iOS)
                .scaleEffect(0.75)
            #endif
            .frame(height: 25)
            .fixedSize()

    }
}

public struct NodeColor4Input: View {

    @Binding var value: Color4

    var binding: Binding<CGColor> {
        .init {
            .init(srgbRed: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
        } set: { color in
            let c = color.converted(to: .init(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
            let comps = c.components!
            self.value = .init(red: comps[0], green: comps[1], blue: comps[2], alpha: comps[3])
        }
    }

    public var body: some View {
        ColorPicker("", selection: self.binding, supportsOpacity: true)
            .controlSize(.small)
            #if os(iOS)
                .scaleEffect(0.75)
            #endif
            .frame(height: 25)
            .fixedSize()

    }
}

#Preview("Color3") {
    @Previewable @State var value: Color3 = .init(red: 0, green: 0, blue: 0)

    VStack {
        NodeColor3Input(value: $value)
            .border(.red)
    }
    .padding(100)
}

#Preview("Color4") {
    @Previewable @State var value: Color4 = .init(red: 0, green: 0, blue: 0, alpha: 1)

    VStack {
        NodeColor4Input(value: $value)
            .border(.red)
    }
    .padding(100)
}
