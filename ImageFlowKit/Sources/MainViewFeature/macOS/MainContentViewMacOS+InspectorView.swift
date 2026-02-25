import InspectorFeature
import SharedModels
import SwiftUI

struct InspectorView: View {

    let flow: Flow
    let coordinator: GlobalCoordinator

    var body: some View {
        InspectorFeatureView(flow: flow, coordinator: coordinator)
    }
}
