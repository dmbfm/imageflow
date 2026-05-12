import SharedModels
import SwiftUI

struct CardImagePicker: View {

    @Binding var current: OutputPortLocation?
    let visible: Bool
    let available: Set<PreviewLocation>
    @Namespace var ns

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            GlassEffectContainer {
                VStack {
                    if self.visible && self.available.count >= 2 {
                        #if os(macOS)
                        HStack(spacing: 2) {
                            Image(systemName: "photo.stack.fill")

                            Picker(
                                "",
                                selection: self.$current,
                            ) {
                                ForEach(Array(self.available), id: \.self) { item in
                                    Text("\(item.name)")
                                        .tag(item.location)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.trailing, 4)
                        .padding(.leading, 6)
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 8))
                        .glassEffectUnion(id: "picker", namespace: self.ns)
                        #else
                        HStack {
                            Image(systemName: "photo.stack.fill")
                                .padding(.leading, 8)

                            Picker("", systemImage: "photo.stack.fill", selection: self.$current) {
                                ForEach(Array(self.vm.available), id: \.self) { item in
                                    Text("\(item.name)")
                                        .tag(item.location)
                                }
                            }
                        }
                        .glassEffect(.regular.interactive(), in: .capsule)
                        .glassEffectUnion(id: "picker", namespace: self.ns)
                        #endif
                    }
                }
                .frame(width: 200)
                .padding(.bottom, 12)
            }
        }
    }
}
