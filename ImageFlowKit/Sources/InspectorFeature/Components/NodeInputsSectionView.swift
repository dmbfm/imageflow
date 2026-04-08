import SwiftUI

struct NodeInputsSectionView: View {

    let vm: InspectorFeatureViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Inputs")
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                    .foregroundStyle(.primaryLabel)
                Spacer()
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 0)

            ForEach(self.vm.node.inputs) { input in
                NodeInputPropertyView(vm: self.vm, input: input)
            }
        }
    }
}
