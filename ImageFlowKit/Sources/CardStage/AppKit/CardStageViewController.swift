//#if canImport(AppKit)
//
//import AppKit
//import Helpers
//import SwiftUI
//
//// MARK: - Model
//
//struct CardStage {
//
//    struct Model: Equatable {
//        var alignment: Alignment
//        var size: CGSize
//        var insets: Insets
//
//        init(
//            alignment: Alignment = .bottomRight,
//            size: CGSize = .init(width: 250, height: 250),
//            insets: Insets = .init(left: 10, right: 10, top: 10, bottom: 10),
//        ) {
//            self.alignment = alignment
//            self.size = size
//            self.insets = insets
//        }
//    }
//
//    enum Alignment: String, Equatable, CaseIterable, Identifiable {
//        var id: Self { self }
//        case topLeft
//        case topRight
//        case bottomLeft
//        case bottomRight
//
//        func point(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) -> CGPoint {
//            switch self {
//            case .topLeft: .init(x: minX, y: minY)
//            case .topRight: .init(x: maxX, y: minY)
//            case .bottomLeft: .init(x: minX, y: maxY)
//            case .bottomRight: .init(x: maxX, y: maxY)
//            }
//        }
//    }
//
//    struct Insets: Equatable {
//        var left: CGFloat
//        var right: CGFloat
//        var top: CGFloat
//        var bottom: CGFloat
//    }
//}
//
//// MARK: - Controller
//
//extension CardStage {
//    final class Controller: NSViewController, MainViewDelegate {
//
//        var model: Model {
//            didSet {
//                if self.model != oldValue {
//                    self.stageView.upadateModel(self.model)
//                    self.delegate?.cardStateControllerDelegateModelDidChange(self.model)
//                }
//            }
//        }
//
//        var contentView: PlatformView {
//            get { self.cardView.contentView }
//            set { self.cardView.contentView = newValue }
//        }
//
//        var stageView: MainView!
//        var cardView: CardView!
//        weak var delegate: Delegate?
//
//        protocol Delegate: AnyObject {
//            func cardStateControllerDelegateModelDidChange(_ model: Model)
//        }
//
//        init(_ model: Model) {
//            self.model = model
//            super.init(nibName: nil, bundle: nil)
//            self.view.clipsToBounds = false
//        }
//
//        required init?(coder: NSCoder) {
//            nil
//        }
//
//        override func loadView() {
//            self.stageView = .init()
//            self.cardView = self.stageView.cardView
//            self.stageView.delegate = self
//            self.view = self.stageView
//        }
//
//        override func viewDidLoad() {
//            self.stageView.upadateModel(self.model)
//        }
//
//        func setAlignment(_ alignment: Alignment) {
//            self.stageView.setAlignment(alignment, animating: true)
//            self.model.alignment = alignment
//        }
//
//        func mainViewModelDidChange(_ model: CardStage.Model) {
//            if self.model != model {
//                self.model = model
//            }
//        }
//    }
//}
//
//// MARK: - Geometry
//
//extension CardStage {
//
//    struct Geometry {
//        let origin: CGPoint
//        let anchor: CGPoint
//        let size: CGSize
//        let corners: Corners
//        let resizeDragRects: DragRects
//        let closestAlignment: Alignment
//
//        struct Corners {
//            var topLeft: CGPoint
//            var topRight: CGPoint
//            var bottomLeft: CGPoint
//            var bottomRight: CGPoint
//        }
//
//        struct DragRects {
//            var horizontal: CGRect
//            var vertical: CGRect
//            var corner: CGRect
//
//            enum Handle {
//                case horizontal
//                case vertical
//                case corner
//            }
//
//            init(horizontal: CGRect, vertical: CGRect, corner: CGRect) {
//                self.horizontal = horizontal
//                self.vertical = vertical
//                self.corner = corner
//            }
//
//            init(alignment: Alignment, origin: CGPoint, size: CGSize, thickness: CGFloat) {
//                self.horizontal =
//                    switch alignment {
//                    case .topLeft, .topRight:
//                        .init(
//                            x: origin.x,
//                            y: origin.y + size.height - thickness,
//                            width: size.width,
//                            height: thickness
//                        )
//                    case .bottomLeft, .bottomRight:
//                        .init(x: origin.x, y: origin.y, width: size.width, height: thickness)
//                    }
//
//                self.vertical =
//                    switch alignment {
//                    case .topLeft, .bottomLeft:
//                        .init(
//                            x: origin.x + size.width - thickness,
//                            y: origin.y,
//                            width: thickness,
//                            height: size.height
//                        )
//                    case .topRight, .bottomRight:
//                        .init(x: origin.x, y: origin.y, width: thickness, height: size.height)
//                    }
//                self.corner =
//                    switch alignment {
//                    case .bottomRight: .init(x: origin.x, y: origin.y, width: 2 * thickness, height: 2 * thickness)
//                    case .bottomLeft:
//                        .init(
//                            x: origin.x + size.width - 2 * thickness,
//                            y: origin.y,
//                            width: 2 * thickness,
//                            height: 2 * thickness
//                        )
//                    case .topLeft:
//                        .init(
//                            x: origin.x + size.width - 2 * thickness,
//                            y: origin.y + size.height - 2 * thickness,
//                            width: 2 * thickness,
//                            height: 2 * thickness
//                        )
//                    case .topRight:
//                        .init(
//                            x: origin.x,
//                            y: origin.y + size.height - 2 * thickness,
//                            width: 2 * thickness,
//                            height: 2 * thickness
//                        )
//                    }
//            }
//
//            func hitTest(_ point: CGPoint) -> Handle? {
//                if self.horizontal.contains(point) {
//                    return .horizontal
//                } else if self.vertical.contains(point) {
//                    return .vertical
//                } else if self.corner.contains(point) {
//                    return .corner
//                }
//
//                return nil
//            }
//
//            func contains(_ point: CGPoint) -> Bool {
//                self.horizontal.contains(point) || self.vertical.contains(point)
//            }
//
//            func allContains(_ point: CGPoint) -> Bool {
//                self.horizontal.contains(point) && self.vertical.contains(point)
//            }
//        }
//
//        init(
//            model: Model,
//            state: MainView.State,
//            bounds: CGRect,
//            dragRectSize: CGFloat = 10,
//        ) {
//            let insets = model.insets
//            let alignment = model.alignment
//            let stageRect = bounds
//            let offset = state.offset
//
//            var size = model.size
//            var anchor: CGPoint = .zero
//            var origin: CGPoint = .zero
//            var corners: Corners = .init(topLeft: .zero, topRight: .zero, bottomLeft: .zero, bottomRight: .zero)
//            var minX: CGFloat = 0
//            var minY: CGFloat = 0
//            var maxX: CGFloat = 0
//            var maxY: CGFloat = 0
//
//            for _ in 0..<2 {
//
//                minX = insets.left
//                maxX = stageRect.width - insets.right - size.width
//                minY = insets.top
//                maxY = stageRect.height - insets.bottom - size.height
//
//                anchor =
//                    switch alignment {
//                    case .topLeft:
//                        .init(x: minX, y: minY)
//                    case .topRight:
//                        .init(x: maxX, y: minY)
//                    case .bottomLeft:
//                        .init(x: minX, y: maxY)
//                    case .bottomRight:
//                        .init(x: maxX, y: maxY)
//                    }
//
//                origin = anchor + offset.cgPoint
//
//                corners = Corners(
//                    topLeft: origin,
//                    topRight: origin + .init(x: size.width, y: 0),
//                    bottomLeft: origin + .init(x: 0, y: size.height),
//                    bottomRight: origin + size.cgPoint
//                )
//
//                guard let resizingData = state.resizing else { break }
//
//                // func conv(_ point: CGPoint) -> CGPoint {
//                //     switch alignment {
//                //     case .topLeft:
//                //         return point - origin
//                //     case .bottomLeft:
//                //         let p = point - corners.bottomLeft
//                //         return .init(x: p.x, y: -p.y)
//                //     case .topRight:
//                //         let p = point - corners.topRight
//                //         return .init(x: -p.x, y: p.y)
//                //     case .bottomRight:
//                //         let p = point - corners.bottomRight
//                //         return -p
//                //     }
//                // }
//
//                func conv(_ size: CGSize) -> CGSize {
//                    switch alignment {
//                    case .topLeft:
//                        return size
//                    case .bottomLeft:
//                        let p = size
//                        return .init(width: p.width, height: -p.height)
//                    case .topRight:
//                        let p = size
//                        return .init(width: -p.width, height: p.height)
//                    case .bottomRight:
//                        let p = size
//                        return -p
//                    }
//                }
//
//                let p = conv(resizingData.translation)
//
//                let limits = resizingData.limits
//
//                let s1 = max(limits.lowerBound, min(limits.upperBound, resizingData.initialSize.width + p.width))
//                let s2 = max(limits.lowerBound, min(limits.upperBound, resizingData.initialSize.height + p.height))
//                let s =
//                    switch resizingData.handle {
//                    case .horizontal: s2
//                    case .vertical: s1
//                    case .corner: max(s1, s2)
//                    }
//
//                size = .init(width: s, height: s)
//            }
//
//            let resizeDragRects = DragRects(alignment: alignment, origin: origin, size: size, thickness: dragRectSize)
//
//            let closestAlignment: Alignment = Alignment.allCases.reduce(
//                (alignment, CGFloat.greatestFiniteMagnitude),
//                { acc, item in
//                    let point = item.point(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
//                    let d = origin.distance(to: point)
//                    return if d < acc.1 {
//                        (item, d)
//                    } else {
//                        acc
//                    }
//                }
//            ).0
//
//            self.origin = origin
//            self.anchor = anchor
//            self.size = size
//            self.resizeDragRects = resizeDragRects
//            self.corners = corners
//            self.closestAlignment = closestAlignment
//        }
//    }
//}
//
//// MARK: - Main View
//
//extension CardStage {
//
//    protocol MainViewDelegate: AnyObject {
//        func mainViewModelDidChange(_ model: Model)
//    }
//
//    final class MainView: PlatformCommonView {
//
//        var contentView: PlatformView {
//            get { self.cardView.contentView }
//            set { self.cardView.contentView = newValue }
//        }
//
//        var cardView: CardView
//        weak var delegate: MainViewDelegate?
//
//        private var model: Model = .init() {
//            didSet {
//                if self.model != oldValue {
//                    self.delegate?.mainViewModelDidChange(self.model)
//                    self.setNeedsLayout()
//                }
//            }
//        }
//
//        var state: State = .idle {
//            didSet {
//                if self.state != oldValue {
//                    self.setNeedsLayout()
//                }
//            }
//        }
//
//        var geometry: Geometry
//
//        enum State: Equatable {
//            case idle
//            case resizing(Resizing)
//            case dragging(offset: CGSize)
//
//            struct Resizing: Equatable, With {
//                var initialSize: CGSize
//                var translation: CGSize
//                var limits: ClosedRange<CGFloat>
//                var handle: Geometry.DragRects.Handle
//            }
//
//            var offset: CGSize {
//                switch self {
//                case .dragging(let offset): offset
//                default: .zero
//                }
//            }
//
//            var resizing: Resizing? {
//                switch self {
//                case .resizing(let value): value
//                default: nil
//                }
//            }
//        }
//
//        struct AnimationState: Equatable {
//        }
//
//        init() {
//            self.cardView = .init()
//            self.geometry = .init(model: self.model, state: self.state, bounds: .zero)
//
//            super.init(frame: .zero)
//
//            self.addSubview(self.cardView)
//
//            let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
//            self.cardView.addGestureRecognizer(panGesture)
//
//            self.geometry = .init(model: self.model, state: self.state, bounds: self.bounds)
//        }
//
//        required init?(coder: NSCoder) {
//            nil
//        }
//
//        override func resetCursorRects() {
//            self.discardCursorRects()
//            self.addCursorRect(self.geometry.resizeDragRects.horizontal, cursor: .windowResizeNorthSouthCursor)
//            self.addCursorRect(self.geometry.resizeDragRects.vertical, cursor: .windowResizeEastWestCursor)
//            self.addCursorRect(
//                self.geometry.resizeDragRects.corner,
//                cursor: {
//                    switch self.model.alignment {
//                    case .topLeft, .bottomRight: .windowResizeNorthWestSouthEastCursor
//                    default: .windowResizeNorthEastSouthWestCursor
//                    }
//                }()
//            )
//        }
//
//        func updateGeometry() {
//            self.geometry = .init(
//                model: self.model,
//                state: self.state,
//                bounds: self.bounds
//            )
//            self.window?.invalidateCursorRects(for: self)
//        }
//
//        @objc func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
//            let t = {
//                let t = gesture.translation(in: nil)
//                return CGSize(width: t.x, height: -t.y)
//            }()
//
//            switch gesture.state {
//            case .possible:
//                break
//            case .began:
//                let rects = self.geometry.resizeDragRects
//                let location = self.convert(gesture.location(in: nil), from: nil)
//
//                if let handle = rects.hitTest(location) {
//                    self.state = .resizing(
//                        .init(
//                            initialSize: self.geometry.size,
//                            translation: t,
//                            limits: 50...500,
//                            handle: handle
//                        )
//                    )
//                } else {
//                    self.state = .dragging(offset: .zero)
//                }
//
//            case .changed:
//                switch self.state {
//                case .dragging:
//                    self.state = .dragging(offset: t)
//                    self.updateGeometry()
//                    self.setNeedsLayout()
//                case .resizing(let value):
//                    self.state = .resizing(value.with(\.translation, t))
//                    self.updateGeometry()
//                    self.setNeedsLayout()
//                case .idle:
//                    break
//                }
//
//            case .ended, .cancelled, .failed:
//
//                switch self.state {
//                case .dragging:
//                    let newAlignment = self.geometry.closestAlignment
//                    if newAlignment != self.model.alignment {
//                        self.model.alignment = newAlignment
//                    }
//                    self.cardView.animator().frame.origin = self.geometry.anchor
//                    self.state = .idle
//
//                case .resizing:
//                    self.model.size = self.geometry.size
//                    self.state = .idle
//
//                case .idle:
//                    break
//                }
//
//            @unknown default:
//                break
//            }
//        }
//
//        func upadateModel(_ model: Model) {
//            if model != self.model {
//                self.model = model
//                self.updateGeometry()
//                self.needsLayout = true
//            }
//        }
//
//        func setAlignment(_ alignment: Alignment, animating: Bool = true) {
//            if animating {
//                self.model.alignment = alignment
//                self.updateGeometry()
//                self.cardView.animator().frame.origin = self.geometry.anchor
//            } else {
//                self.model.alignment = alignment
//                self.updateGeometry()
//                self.setNeedsLayout()
//            }
//        }
//
//        override func layout() {
//            super.layout()
//            self.updateGeometry()
//            self.cardView.frame.size = self.geometry.size
//            self.cardView.frame.origin = self.geometry.origin
//        }
//    }
//}
//
//// MARK: - Card View
//
//extension CardStage {
//    final class CardView: PlatformCommonView {
//
//        var contentView: PlatformView {
//            didSet {
//                self.setupContentView()
//            }
//        }
//
//        func setupContentView() {
//            for s in self.subviews {
//                s.removeFromSuperview()
//            }
//            self.contentView.autoresizingMask = [.width, .height]
//            self.contentView.clipsToBounds = true
//            self.contentView.wantsLayer = true
//            self.contentView.layer?.cornerRadius = 10
//            self.contentView.layer?.cornerCurve = .continuous
//            self.contentView.layer?.masksToBounds = true
//            self.addSubview(self.contentView)
//        }
//
//        override init(frame frameRect: NSRect) {
//            self.contentView = DefaultContentView(frame: .zero)
//            super.init(frame: frameRect)
//
//            self.wantsLayer = true
//            self.layer?.backgroundColor = .clear  //NSColor.systemMint.cgColor
//            self.layer?.cornerRadius = 10
//            self.layer?.cornerCurve = .continuous
//
//            self.shadow = .init()
//
//            self.layer?.shadowColor = CGColor(gray: 0.5, alpha: 0.5)
//            self.layer?.shadowRadius = 8
//            self.layer?.shadowOpacity = 1.0
//            self.layer?.shadowOffset = .zero
//            self.layer?.masksToBounds = false
//
//            self.autoresizesSubviews = true
//            self.setupContentView()
//        }
//
//        required init?(coder: NSCoder) {
//            nil
//        }
//    }
//
//    final class DefaultContentView: PlatformCommonView {
//        override init(frame frameRect: NSRect) {
//            super.init(frame: frameRect)
//            self.wantsLayer = true
//            self.layer?.backgroundColor = .red
//        }
//
//        required init?(coder: NSCoder) {
//            nil
//        }
//    }
//}
//
//extension NSCursor {
//    @MainActor static let windowResizeNorthWestSouthEastCursor =
//        NSCursor.value(forKey: "_windowResizeNorthWestSouthEastCursor") as? NSCursor ?? NSCursor.columnResize
//    @MainActor static let windowResizeNorthEastSouthWestCursor =
//        NSCursor.value(forKey: "_windowResizeNorthEastSouthWestCursor") as? NSCursor ?? NSCursor.columnResize
//    @MainActor static let windowResizeEastWestCursor =
//        NSCursor.value(forKey: "_windowResizeEastWestCursor") as? NSCursor ?? .columnResize
//    @MainActor static let windowResizeNorthSouthCursor =
//        NSCursor.value(forKey: "_windowResizeNorthSouthCursor") as? NSCursor ?? .rowResize
//}
//
//// MARK: - Previews
//
//extension CardStage {
//    struct PreviewRepresentable: NSViewControllerRepresentable {
//
//        @Binding var model: Model
//
//        func makeNSViewController(context: Context) -> CardStage.Controller {
//            let view = CardStage.Controller(self.model)
//            view.delegate = context.coordinator
//            view.contentView = NSHostingView(
//                rootView: ZStack {
//                    Color.purple
//                    Text("Card View!!")
//                        .foregroundStyle(.white)
//                }
//            )
//            return view
//        }
//
//        func updateNSViewController(_ vc: CardStage.Controller, context: Context) {
//
//            if vc.model.alignment != self.model.alignment {
//                vc.setAlignment(self.model.alignment)
//            }
//
//            if vc.model != self.model {
//                vc.model = self.model
//            }
//
//            context.coordinator.model = self.$model
//        }
//
//        func makeCoordinator() -> Coordinator {
//            .init()
//        }
//
//        class Coordinator: CardStage.Controller.Delegate {
//            var model: Binding<Model>?
//            func cardStateControllerDelegateModelDidChange(_ model: CardStage.Model) {
//                if let binding = self.model, binding.wrappedValue != model {
//                    binding.wrappedValue = model
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    @Previewable @State var model: CardStage.Model = .init()
//
//    VStack {
//        CardStage.PreviewRepresentable(model: $model)
//            .frame(minWidth: 800, minHeight: 600)
//            .padding()
//            .border(.gray)
//
//        Divider()
//
//        VStack {
//            Picker("", selection: $model.alignment) {
//                ForEach(CardStage.Alignment.allCases) { item in
//                    Text("\(item.rawValue)").tag(item)
//                }
//            }
//            Text("size: \(model.size, default: "")")
//        }
//        .padding()
//    }
//}
//
//#endif
