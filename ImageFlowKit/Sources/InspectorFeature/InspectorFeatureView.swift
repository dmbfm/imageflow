import Design
import SharedMocking
import SharedModels
import SwiftUI
import Helpers
import Controls
import Logging

public struct BaseBlock<Content: View>: View {
    
    struct Style: With {
        var padding: SwiftUI::EdgeInsets  = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        var cornerRadius: CGFloat = 8.0
        var fill: AnyShapeStyle = .init(.primaryFill)
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
        .frame(maxWidth: .infinity)
        .padding(self.style.padding)
        .background {
            RoundedRectangle(cornerRadius: self.style.cornerRadius, style: .continuous)
                .fill(self.style.fill)
                .strokeBorder(self.style.border)
        }
    }
}

public struct InspectorFeatureView: View {
    
    @Environment(\.inspectorStyle) var style
    
    init(flow: Flow, assetStore: any AssetStoreService, coordinator: GlobalCoordinator) {}
    
    @State var boolValue: Bool = false
    @State var text: String = "258.00"
    
    @FocusState var focused: Bool
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Inputs")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundStyle(.primaryLabel)
                        Spacer()
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 8)
                
                    VStack {
                        BaseBlock(style: .default.with(\.cornerRadius, 10)) {
                            HStack(spacing: 4) {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "arrow.backward.circle")
                                    //                                    Image(systemName: "circle.dotted")
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondaryLabel)
                                }
                                .buttonStyle(.plain)
                                
                                Text("Enabled")
                                //                                    .fontWeight(.medium)
                                //                                    .font(.body)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.primaryLabel)
                                Spacer()
                                Toggle("", isOn: self.$boolValue)
                                    .toggleStyle(.switch)
                            }
                        }
                        
                        BaseBlock(style: .default) {
                            HStack(spacing: 4) {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "arrow.backward.circle")
//                                    Image(systemName: "circle.dotted")
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondaryLabel)
                                }
                                .buttonStyle(.plain)
                                
                                Text("Texture")
//                                    .fontWeight(.medium)
//                                    .font(.body)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.primaryLabel)
                                Spacer()
                            }
                            .padding(.bottom, 5)
                            
                            VStack {
                                ZStack(alignment: .trailing) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(.secondaryFill)
//                                        .strokeBorder(.primaryFill)
                                        .frame(height: 28)
                                    
                                    Text("258.00")
                                        .font(.body)
                                        .foregroundStyle(.primaryLabel)
                                        .padding(.trailing, 6)
                                }
                                
                                TextField("", text: self.$text)
                                    .multilineTextAlignment(.trailing)
                                    .textFieldStyle(kind: .roundedBorder)
                                
                                NumberInputView(value: 0.5, configuration: .free(.init())) { _ in }
                                    .multilineTextAlignment(.trailing)
                                    .betterTextFieldBorderShapeStyle(.secondaryFill)
                                
//                                 TextFieldEx(text: self.$text)
// //                                    .fixedSize()
//                                     .textFieldExStyle(.plain)
//                                     .textFieldExInteractionMode(.commit)
//                                     .textFieldExDidBeginEditing { value in
// //                                        log("begin!")
// //                                        self.focused = false
//                                     }
//                                     .textFieldExDidEndEditing { value in
//                                         self.focused = false
//                                     }
//                                     .textFieldExCancelAction {  
//                                         self.focused = false
//                                     }
//                                     .focused(self.$focused)
// //                                    .border(.red)
//                                     .multilineTextAlignment(.trailing)
//                                     .padding()
//                                     .background {}
//                                     .clipShape(Rectangle())
//                                     .background {
//                                         Rectangle()
//                                             .fill(.secondaryFill)
//                                     }
//                                     .clipShape(Rectangle())
//                                     .gesture(ValueDragGesture(focused: self.focused, handler: { value in log("value: \(value)") }))
// //                                    .gesture(DragGesture().onChanged({ value in log("value: \(value)")}))
//                                     .border(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal, self.style.paddingHorizontal)
                .padding(.top, 10)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .safeAreaBar(edge: .top) {
                self.nodeTitleView
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }
    
    var  nodeTitleView: some View {
        HStack {
            Image(systemName: "camera.filters")
                .foregroundStyle(.secondaryLabel)
                .font(.headline)
            Text("Dot Screen")
                .font(.headline)
                .foregroundStyle(.primaryLabel)
            Spacer()
            Button("", systemImage: "lock.open") {}
                .buttonStyle(.plain)
                .foregroundStyle(.secondaryLabel)
            Button("", systemImage: "ellipsis") {}
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
        
        public init() {
            let flow = Flow()
            
            self._flow = .init(wrappedValue: flow)
            self._coordinator = .init(wrappedValue: .init(MockGlobalCoordinatorService(flow: flow)))
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

#Preview {
    InspectorFeatureView.Preview()
        .frame(width: 600, height: 500)
}
