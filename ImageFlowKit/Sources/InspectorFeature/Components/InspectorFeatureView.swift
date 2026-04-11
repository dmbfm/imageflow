import Controls
import Design
import Helpers
import Logging
import SharedMocking
import SharedModels
import SwiftUI
import Values

// MARK: - InspectorFeatureView

public struct InspectorFeatureView: View {

    @ObservableState var vm: InspectorFeatureViewModel

    @Environment(\.inspectorStyle) var style
    @Environment(\.undoManager) var um

    init(flow: Flow, assetStore: any AssetStoreService, coordinator: GlobalCoordinator) {
        self._vm = .init(
            wrappedValue: .init(
                flow: flow,
                coordinator: coordinator,
                assetStore: assetStore,
                undoManager: nil
            )
        )
    }

    @State var boolValue: Bool = false
    @State var text: String = "258.00"

    @FocusState var focused: Bool

    public var body: some View {
        self.content
            .onChange(of: self.um, initial: true, { self.vm.undoManager = self.um })
    }

    @ViewBuilder
    public var content: some View {
        Group {
            if self.vm.hasNode {
                self.nodeContentView
            } else {
                ContentUnavailableView(
                    "No Node Selected",
                    systemImage: "list.bullet.rectangle.portrait.fill",
                    description: Text("Select a node to inspect it")
                )
            }
        }
    }

    @ViewBuilder
    public var nodeContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    NodeTypeBlockView(vm: self.vm)
                        .padding(.bottom, 10)

                    if self.vm.node.inputs.count > 0 {
                        NodeInputsSectionView(vm: self.vm)
                    }

                    if self.vm.node.outputs.count > 0 {
                        NodeOutputsSectionView(vm: self.vm)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, self.style.paddingHorizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .safeAreaBar(edge: .top) {
                NodeTitleView(vm: self.vm)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }
}

extension InspectorFeatureView {
    struct Style {
        let paddingHorizontal: CGFloat = 10
        let paddingTop: CGFloat = 10
        let paddingNodeTitleBottom: CGFloat = 10

        static var `default`: Self {
            .init()
        }
    }
}

extension EnvironmentValues {
    @Entry var inspectorStyle: InspectorFeatureView.Style = .default
}

extension View {
    func inspectorStyle(_ value: InspectorFeatureView.Style) -> some View {
        self.environment(\.inspectorStyle, value)
    }
}

extension InspectorFeatureView {

    public struct Preview: View {

        @State var flow: Flow
        @State var assetStore: MockAssetStore = .init()
        @State var coordinator: GlobalCoordinator

        public init(_ nodes: [FlowNode] = [], _ selected: UUID? = nil) {
            let flow = Flow()

            self._flow = .init(wrappedValue: flow)
            self._coordinator = .init(wrappedValue: .init(MockGlobalCoordinatorService(flow: flow)))

            for node in nodes {
                flow.addNode(node, at: .zero)
            }

            if let first = nodes.first {
                flow.select([selected ?? first.id])
            }
        }

        public var body: some View {
            ZStack {
                Colors.canvasBackground.color
                    .ignoresSafeArea()
            }
            .inspectorFeatureViewBar(
                .constant(true),
                flow: self.flow,
                assetStore: self.assetStore,
                coordinator: self.coordinator
            )
        }
    }
}

#Preview("Float Node") {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.float))])
        .frame(width: 600, height: 500)
}

#Preview("Int Node") {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.int))])
        .frame(width: 600, height: 500)
}

#Preview("Add Node") {
    InspectorFeatureView.Preview([.init(kind: .math(.addNode(.float)))])
        .frame(width: 600, height: 500)
}

#Preview("Dot Screen") {
    InspectorFeatureView.Preview([.init(kind: .coreImageFilterNode(.halftoneEffect(.CIDotScreen)))])
        .frame(width: 600, height: 500)
}

#Preview("Perspective Rotate") {
    InspectorFeatureView.Preview([.init(kind: .coreImageFilterNode(.geometryAdjustment(.CIPerspectiveRotate)))])
        .frame(width: 600, height: 500)
}

#Preview("No Selection") {
    InspectorFeatureView.Preview()
        .frame(width: 600, height: 500)
}
