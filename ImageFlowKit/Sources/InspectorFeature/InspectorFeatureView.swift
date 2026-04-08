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

                    if self.vm.node.inputs.count > 0 {
                        InputsSectionView(vm: self.vm)
                    }

                }
                .padding(.horizontal, self.style.paddingHorizontal)
                .padding(.top, 10)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .safeAreaBar(edge: .top) {
                NodeTitleView(vm: self.vm)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }
}

// MARK: - InputsSectionView

struct InputsSectionView: View {

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
                InputPropertyView(vm: self.vm, input: input)
            }
        }
    }
}

// MARK: - InputPropertyView

struct InputPropertyView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch input.value.type {
        case .float:
            InputPropertyFloatView(vm: self.vm, input: input)
        case .vector2, .vector3, .vector4:
            InputPropertyVectorView(vm: self.vm, input: input)
        default:
            BaseBlock {
                HStack {
                    NodeInputPropertyTitleView(name: input.label, connected: false)
                    Spacer()
                    Text("TODO: \(input.value.type.displayName)")
                }
            }
        }
    }
}

// MARK: - InputPropertyFloatView

struct InputPropertyVectorView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var dim: Int {
        switch self.input.value.type {
        case .vector2: 2
        case .vector3: 3
        case .vector4: 4
        default: 0
        }
    }

    static let label: [String] = ["X", "Y", "Z", "W"]

    func floatValue(_ index: Int) -> Double {
        switch self.input.value {
        case .vector2(let v): v[index]
        case .vector3(let v): v[index]
        case .vector4(let v): v[index]
        default: 0.0
        }
    }

    func value(settingIndex index: Int, to value: Double) -> Value {
        switch self.input.value {
        case .vector2(var v):
            v[index] = value
            return .vector2(v)
        case .vector3(var v):
            v[index] = value
            return .vector3(v)
        case .vector4(var v):
            v[index] = value
            return .vector4(v)
        default:
            return .vector2(.zero)
        }
    }

    func onChange(_ idx: Int, _ change: NumberInputView.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                self.value(settingIndex: idx, to: change.newValue),
                change.oldValue.map({ self.value(settingIndex: idx, to: $0) })
            ),
            registerUndo: change.commit,
        )
    }

    var body: some View {
        BaseBlock {
            VStack(alignment: .leading) {
                NodeInputPropertyTitle(vm: self.vm, input: self.input)
                VStack {
                    ForEach(0..<self.dim, id: \.self) { idx in
                        HStack {
                            Text(Self.label[idx])
                                .font(.system(size: 10))
                                .bold()
                                .foregroundStyle(.secondaryLabel)
                            NumberInputView(
                                value: self.floatValue(idx),
                                configuration: .free(.init()),
                                onChange: { self.onChange(idx, $0) },
                                onDragStateChange: { _ in }
                            )
                            .inspectorNumberInput()
                        }
                    }
                }
                // NumberInputView(
                //     value: self.value,
                //     configuration: self.numberInputConfiguration,
                //     onChange: self.onChange(_:),
                //     onDragStateChange: { _ in }
                // )
                // .inspectorNumberInput()
            }
        }
    }
}

// MARK: - InputPropertyFloatView

struct InputPropertyFloatView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch input.semantics {
        case .float(.angle(.none)):
            AngleInput(vm: self.vm, input: self.input)
        case .float(.angle(.some(let range))):
            AngleInput(vm: self.vm, input: self.input, range: range)
        case .float(.range(let range)):
            DefaultInput(vm: self.vm, input: self.input, range: range)
        default:
            DefaultInput(vm: self.vm, input: self.input)
        }
    }

    struct AngleInput: View {
        let vm: InspectorFeatureViewModel
        let input: FlowNode.Input
        var range: ClosedRange<Double>?

        @State var unit: AngleUnit = .degrees

        var effectiveUnit: AngleUnit {
            if self.input.connected {
                .radians
            } else {
                self.unit
            }
        }

        var value: Double {
            self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
        }

        var transformedValue: Double {
            self.value.fromRadians(to: self.unit)
        }

        var transformedRange: ClosedRange<Double>? {
            switch self.unit {
            case .degrees:
                self.range.map({ range in
                    let lower = range.lowerBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
                    let upper = range.upperBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
                    return lower...upper
                })
            case .radians:
                self.range
            }
        }

        func onChange(_ change: NumberInputView.Change) {
            log("change: \(change)")
            self.vm.submit(
                .input(
                    self.input.index,
                    .float(change.newValue.toRadians(from: self.unit)),
                    change.oldValue.map({ .float($0.toRadians(from: self.unit)) })
                ),
                registerUndo: change.commit
            )
        }

        var snapping: NumberInputView.Configuration.Snapping {
            switch self.unit {
            case .degrees: .init(increments: 45.0, epsilon: 10.0, enabled: self.snap, modifier: [.option])
            case .radians:
                .init(increments: 45.0.radians, epsilon: 10.0.radians, enabled: self.snap, modifier: [.option])
            }
        }

        var numberInputConfiguration: NumberInputView.Configuration {
            if let range = self.transformedRange {
                .range(.init(snapping: self.snapping, range: range))
            } else {
                .free(.init(snapping: self.snapping))
            }
        }

        @State var snap: Bool = false

        var body: some View {
            BaseBlock {
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        NodeInputPropertyTitle(vm: self.vm, input: self.input)
                        Spacer()
                        Picker("", selection: self.$unit) {
                            Text("Degrees").tag(AngleUnit.degrees)
                            Text("Radians").tag(AngleUnit.radians)
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.borderless)
                        .controlSize(.small)

                        Toggle(isOn: self.$snap) {
                            Image(systemName: "lines.measurement.horizontal.aligned.bottom")
                        }
                        .toggleStyle(.button)
                        .controlSize(.small)
                    }
                    HStack {
                        AngleDial(angle: self.value, range: self.range)
                        NumberInputView(
                            value: self.transformedValue,
                            configuration: self.numberInputConfiguration,
                            onChange: self.onChange(_:),
                            onDragStateChange: { _ in }
                        )
                        .inspectorNumberInput()
                    }
                }
            }
        }
    }

    struct DefaultInput: View {
        let vm: InspectorFeatureViewModel
        let input: FlowNode.Input
        var range: ClosedRange<Double>?

        var value: Double {
            self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
        }

        func onChange(_ change: NumberInputView.Change) {
            self.vm.submit(
                .input(
                    self.input.index,
                    .float(change.newValue),
                    change.oldValue.map({ .float($0) })
                ),
                registerUndo: change.commit
            )
        }

        var numberInputConfiguration: NumberInputView.Configuration {
            if let range = self.range {
                .range(.init(range: range))
            } else {
                .free(.init())
            }
        }

        var body: some View {
            BaseBlock {
                VStack(alignment: .leading) {
                    NodeInputPropertyTitle(vm: self.vm, input: self.input)
                    NumberInputView(
                        value: self.value,
                        configuration: self.numberInputConfiguration,
                        onChange: self.onChange(_:),
                        onDragStateChange: { _ in }
                    )
                    .inspectorNumberInput()
                }
            }
        }
    }
}

extension NumberInputView {
    func inspectorNumberInput() -> some View {
        self
            .multilineTextAlignment(.trailing)
            .betterTextFieldBorderShapeStyle(.secondaryFill)
    }
}

// MARK: - BaseBlock

public struct BaseBlock<Content: View>: View {

    struct Style: With {
        var padding: SwiftUI::EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        var cornerRadius: CGFloat = 8.0
        var fill: AnyShapeStyle = .init(.tertiaryFill)
        var border: AnyShapeStyle = .init(.clear)

        static var `default`: Self { .init() }

    }

    var style: Style
    var content: () -> Content

    init(style: Style = .default, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(self.style.padding)
        .background {
            RoundedRectangle(cornerRadius: self.style.cornerRadius, style: .continuous)
                .fill(self.style.fill)
                .strokeBorder(self.style.border)
        }
    }
}

// MARK: - NodeInputPropertyTitle

struct NodeInputPropertyTitle: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        NodeInputPropertyTitleView(name: input.label, connected: input.connected) {
            self.vm.flow.select(nodeConnectedToNode: self.vm.node.id, atInputPort: self.input.index)
        }
    }
}

struct NodeInputPropertyTitleView: View {

    var name: String
    var connected: Bool
    var onTapConnectedButton: (() -> ())?

    var icon: String {
        if self.connected {
            "arrow.backward.circle"
        } else {
            "circle.dotted"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Button {
                self.onTapConnectedButton?()
            } label: {
                Image(systemName: self.icon)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondaryLabel)
            }
            .buttonStyle(.plain)
            .disabled(!self.connected)

            Text(self.name)
                .font(.system(size: 12))
                .foregroundStyle(.primaryLabel)
        }
    }
}

// MARK: - NodeTitleView

struct NodeTitleView: View {

    @Environment(\.inspectorStyle) var style
    let vm: InspectorFeatureViewModel

    var node: FlowNode {
        self.vm.node
    }

    var lockIcon: String {
        if self.vm.isLocked {
            "lock"
        } else {
            "lock.open"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: node.kind.icon)
                .foregroundStyle(.secondaryLabel)
                .font(.headline)

            Text(node.name)
                .font(.headline)
                .foregroundStyle(.primaryLabel)

            Spacer()

            Button("", systemImage: self.lockIcon) {
                self.vm.toggleLocked()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondaryLabel)

            Button("", systemImage: "ellipsis") {
                log("TODO", level: .error)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondaryLabel)
        }
        .padding(.horizontal, self.style.paddingHorizontal)
        .padding(.top, self.style.paddingTop)
        .padding(.bottom, self.style.paddingNodeTitleBottom)
    }
}

#if os(macOS)
private struct ValueDragGesture: NSGestureRecognizerRepresentable {

    var focused: Bool
    var handler: (Value) -> ()
    @State var startLocation: CGPoint = .zero

    struct Value {
        var state: NSGestureRecognizer.State
        var startLocation: CGPoint
        var location: CGPoint
    }

    func makeNSGestureRecognizer(context: Context) -> NSPanGestureRecognizer {
        let gesture = NSPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
    }

    func updateNSGestureRecognizer(_ recognizer: NSPanGestureRecognizer, context: Context) {
        context.coordinator.focused = self.focused
    }

    func handleNSGestureRecognizerAction(_ recognizer: NSPanGestureRecognizer, context: Context) {
        log("gesture:\(recognizer.state):\(recognizer.translation(in: nil))")

        if recognizer.state == .began {
            self.startLocation = context.converter.location(in: .local)
        }

        self.handler(
            .init(
                state: recognizer.state,
                startLocation: self.startLocation,
                location: context.converter.location(in: .local)
            )
        )
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        .init()
    }

    class Coordinator: NSObject, NSGestureRecognizerDelegate {
        var focused: Bool = false
        func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
            if self.focused {
                return false
            } else {
                return true
            }
        }
        //        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        //            false
        //        }
    }
}
#endif

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
