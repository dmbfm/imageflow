#if canImport(AppKit)
import AppKit
import SwiftUI
import ColorUtils
import CommonUtils
import Design
import EventEmitter
import Logging

// public final class CanvasAppKitView: NSView {

//     // MARK: - Public Properties

//     public var viewport: CanvasViewport {
//         didSet {
//             if self.viewport != oldValue {
//                 self.viewportDidChange()
//             }
//         }
//     }

//     public var nodePositions: [UUID: CGPoint] {
//         didSet {
//             if self.nodePositions != oldValue {
//                 self.nodePositionsDidChange(oldValue)
//             }
//         }
//     }

//     public let configuration: CanvasConfiguration

//     public var onEvent: ((CanvasPlatformView.Event) -> ())?

//     public var viewForNode: (UUID) -> (any CanvasNodeView)?

//     public private(set) var nodeViews: [UUID: any CanvasNodeView] = [:]

//     // MARK: - Private Properties

//     private var scaleAtStartOfMagnification: CGFloat = 1.0
//     private var leftPanInitialPos: CGPoint?

//     // MARK: - Subviews

//     private lazy var gridView: GridView = {
//         let view = GridView()
//         view.onEvent = { [weak self] event in
//             guard let self else { return }
//             switch event {
//             case .scroll(let event):
//                 self.gridView(didScrollWith: event)
//             default:
//                 break
//             }
//         }
//         view.autoresizingMask = [.width, .height]
//         return view
//     }()

//     private lazy var contentView: ContentView = {
//         let view = ContentView()
//         view.autoresizingMask = [.width, .height]
//         return view
//     }()

//     // MARK: - Initializers

//     internal init(
//         viewport: CanvasViewport,
//         configuration: CanvasConfiguration = .init(),
//         nodePositions: [UUID: CGPoint] = [:],
//         viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil }
//     ) {
//         self.viewport = viewport
//         self.configuration = configuration
//         self.nodePositions = nodePositions
//         self.viewForNode = viewForNode

//         super.init(frame: .zero)

//         self.autoresizesSubviews = true
//         self.clipsToBounds = true

//         self.setupGridView()
//         self.setupContentView()

//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//             self.gridViewDraw()
//         }
//     }

//     required init?(coder: NSCoder) {
//         nil
//     }

//     // MARK: - Content View Methods

//     func setupContentView() {
//         self.contentView.frame = self.bounds
//         self.addSubview(self.contentView)
//     }

//     func updateContentView() {
//         self.contentView.bounds = NSRect(
//             origin: self.viewport.origin,
//             size: self.viewport.convert(
//                 self.bounds.size,
//                 from: .screen,
//                 to: .viewport
//             )
//         )
//     }

//     // MARK: - Grid View Methods

//     func setupGridView() {
//         self.gridView.frame = self.bounds
//         self.addSubview(self.gridView)

//         let panGesture = NSPanGestureRecognizer(
//             target: self,
//             action: #selector(self.gridView(panGesture:))
//         )
//         // Middle button mask = 00100
//         panGesture.buttonMask = 4
//         self.gridView.addGestureRecognizer(panGesture)

//         let clickGesture = NSClickGestureRecognizer(
//             target: self,
//             action: #selector(self.gridView(clickGesture:))
//         )
//         self.gridView.addGestureRecognizer(clickGesture)

//         let leftPanGesture = NSPanGestureRecognizer(
//             target: self,
//             action: #selector(self.gridView(leftPanGesture:))
//         )
//         self.gridView.addGestureRecognizer(leftPanGesture)

//         let magnificationGesture = NSMagnificationGestureRecognizer(
//             target: self,
//             action: #selector(self.gridView(magnificationGesture:))
//         )
//         self.gridView.addGestureRecognizer(magnificationGesture)
//     }

//     func gridViewDraw() {
//         self.gridView.draw(viewport: self.viewport)
//     }

//     @objc
//     func gridView(magnificationGesture gesture: NSMagnificationGestureRecognizer) {
//         switch gesture.state {
//         case .began:
//             self.scaleAtStartOfMagnification = self.viewport.scale
//         default:
//             let scale = self.scaleAtStartOfMagnification * (1.0 + gesture.magnification)
//             let location = gesture.location(in: self.gridView)
//             self.viewport.zoom(
//                 self.configuration.clampZoom(scale),
//                 atScreenPoint: location
//             )
//         }
//     }

//     @objc
//     func gridView(didScrollWith event: NSEvent) {
//         if event.subtype == .mouseEvent {
//             let location = self.gridView.convert(event.locationInWindow, from: nil)

//             var scale = self.viewport.scale

//             if event.hasPreciseScrollingDeltas {
//                 scale -= event.scrollingDeltaX
//             } else {
//                 scale -= event.deltaY * self.configuration.scrollWheelSensitivity
//             }

//             self.viewport.zoom(
//                 self.configuration.clampZoom(scale),
//                 atScreenPoint: location
//             )

//         } else {
//             let t = CGSize(width: -event.scrollingDeltaX, height: -event.scrollingDeltaY)
//             self.viewport.translate(by: t, in: .screen)
//         }
//     }

//     @objc func gridView(panGesture gesture: NSPanGestureRecognizer) {
//         let t = gesture.translation(in: self.gridView)
//         gesture.setTranslation(.zero, in: self.gridView)

//         let amount = CGSize(
//             width: -t.x,
//             height: -t.y
//         )
//         self.viewport.translate(by: amount, in: .screen)
//     }

//     @objc func gridView(clickGesture gesture: NSClickGestureRecognizer) {
//         // self.emitter.emit(.clickBackground)
//     }

//     @objc func gridView(leftPanGesture gesture: NSPanGestureRecognizer) {

//         // let shiftDown = NSEvent.modifierFlags.contains(.shift)

//         // if gesture.state == .began {
//         //     self.leftPanInitialPos = gesture.location(in: self.gridView)
//         //     self.emitter.emit(.rectSelectEvent(.started(shiftDown: shiftDown)))
//         //     return
//         // }

//         // if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
//         //     self.leftPanInitialPos = nil
//         //     self.rectSelectionView.selectionRect = .zero
//         //     self.emitter.emit(.rectSelectEvent(.ended))
//         //     return
//         // }

//         // guard let initial = self.leftPanInitialPos else {
//         //     log("initial location not set", level: .error)
//         //     return
//         // }

//         // let gridRect = CGRect(
//         //     origin: initial,
//         //     size: gesture.translation(in: self.gridView).cgSize
//         // )

//         // let contentRect = self.contentView.convert(gridRect, from: self.gridView)

//         // self.rectSelectionView.selectionRect = gridRect

//         // self.emitter.emit(.rectSelectEvent(.modified(shiftDown: shiftDown, rect: contentRect)))
//     }

//     // MARK: - Updates

//     func viewportDidChange() {
//         self.onEvent?(.viewportDidChange(self.viewport))
//         self.gridViewDraw()
//         self.updateContentView()
//     }

//     func nodePositionsDidChange(_ oldValue: [UUID: CGPoint]) {
//         for change in oldValue.difference(from: self.nodePositions) {
//             switch change {
//             case let .added(id, pos):
//                 self.addNode(id, at: pos)
//             case let .removed(id):
//                 self.removeNode(id)
//             case let .modified(id, pos):
//                 self.moveNode(id, to: pos)
//             }
//         }
//     }

//     // MARK: - Node Management

//     private func addNode(_ node: some CanvasNodeView, at position: CGPoint) {
//         node.frame.origin = position
//         node.frame.size = node.intrinsicContentSize
//         let id = node.id
//         node.emitter.on() { [weak self] event in
//             guard let self else { return }
//             switch event {
//             case let .dragGesture(gesture):
//                 switch gesture.phase {
//                 case .changed:
//                     let amount = self.viewport.convert(
//                         .init(width: gesture.dx, height: gesture.dy),
//                         from: .screen,
//                         to: .canvas
//                     )
//                     self.translateNode(id, by: amount)
//                 default:
//                     break
//                 }

//             case .sizeChanged:
//                 node.setFrameSize(node.intrinsicContentSize)

//             case .click:
//                 // self.emitter.emit(.nodeClicked(id))
//                 break

//             case .other(_):
//                 break

//             }
//         }
//         self.nodeViews[node.id] = node
//         self.contentView.addSubview(node)
//         self.contentView.sortSubviews()
//     }

//     private func addNode(_ id: UUID, at position: CGPoint) {
//         if let node = self.viewForNode(id) {
//             self.addNode(node, at: position)
//         } else {
//             log("Missing view for node \(id)")
//         }
//     }

//     private func removeNode(_ id: UUID) {
//         guard let node = self.nodeViews[id] else {
//             log("Node not found: \(id)")
//             return
//         }
//         self.nodeViews.removeValue(forKey: id)
//         node.removeFromSuperview()
//     }

//     private func moveNode(_ id: UUID, to position: CGPoint) {
//         guard let node = self.nodeViews[id] else {
//             log("Node not found: \(id)")
//             return
//         }
//         node.frame.origin = position
//         self.needsLayout = true
//     }

//     private func translateNode(_ id: UUID, by translation: CGSize) {
//         if self.nodePositions[id] == nil {
//             log("Node not found: \(id)")
//             return
//         }

//         let newPos = self.nodePositions[id]! + translation.cgPoint
//         self.nodePositions[id] = newPos
//         self.onEvent?(.nodePositionsDidChange(self.nodePositions))
//         // if let view = self.nodeViews[id] {
//         //     view.setFrameOrigin(newPos)
//         // }
//         // self.emitter.emit(.nodeShouldMove(id, newPos))
//     }
// }

// // MARK: - GridView

// extension CanvasAppKitView {
//     final class GridView: NSView {

//         var viewport: CanvasViewport?

//         var onEvent: ((Event) -> ())?

//         enum Event {
//             case scroll(NSEvent)
//             case mouseEntered
//             case mouseLeft
//         }

//         init() {
//             super.init(frame: .zero)

//             self.wantsLayer = true
//         }

//         required init?(coder: NSCoder) {
//             nil
//         }

//         // MARK: - Drawing

//         override var isFlipped: Bool {
//             true
//         }

//         /// Schedule this view for drawing with the give viewport state and list of edges.
//         ///
//         /// - Parameter viewport: The viewport state.
//         /// - Parameter edges: The list of edges to be drawn.
//         // func draw(viewport: CanvasViewport, edges: [EdgeLayer]) {
//         func draw(viewport: CanvasViewport) {
//             self.viewport = viewport
//             // self.edgesLayersToDraw = edges
//             self.needsDisplay = true
//             self.clipsToBounds = true
//         }

//         override func draw(_ dirtyRect: NSRect) {
//             guard let context = NSGraphicsContext.current?.cgContext else {
//                 return
//             }

//             if let viewport = self.viewport, let layer = self.layer {
//                 self.drawBackgroundTiles(context, layer, viewport)
//             }
//             // self.drawEdges(context)
//         }

//         override func scrollWheel(with event: NSEvent) {
//             self.onEvent?(.scroll(event))
//         }
//     }
// }

// // MARK: - ContentView

// // final class ContentView: NSView {

// //     override var isFlipped: Bool {
// //         true
// //     }

// //     override var isOpaque: Bool {
// //         true
// //     }

// //     override var wantsDefaultClipping: Bool {
// //         false
// //     }

// //     override func hitTest(_ point: NSPoint) -> NSView? {
// //         if let event = NSApp.currentEvent, event.type == .otherMouseDown {
// //             return nil
// //         }

// //         let localPoint = self.convert(point, from: self.superview)
// //         for view in self.subviews.reversed() {
// //             if view.hitTest(localPoint) != nil {
// //                 return super.hitTest(point)
// //             }
// //         }

// //         return nil
// //     }

// //     func sortSubviews() {
// //         self.subviews.sort { a, b in
// //             guard let a = a as? (any CanvasNodeView),
// //                 let b = b as? (any CanvasNodeView)
// //             else { return false }
// //             return a.level < b.level
// //         }
// //     }
// // }

// public class BlueSquareView: NSView, CanvasNodeView {
//     public var id: UUID
//     public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()

//     // Create the button
//     private let centerButton: NSButton = {
//         let button = NSButton(
//             title: "Press Me",
//             target: nil,
//             action: #selector(handleButtonPress(_:))
//         )
//         button.bezelStyle = .rounded
//         button.translatesAutoresizingMaskIntoConstraints = false
//         return button
//     }()

//     // MARK: - Initializers

//     public init(id: UUID, frame frameRect: NSRect) {
//         self.id = id
//         super.init(frame: frameRect)
//         setUpView()
//     }

//     required init?(coder decoder: NSCoder) {
//         nil
//     }

//     // MARK: - Setup

//     private func setUpView() {
//         // Make view layer-backed and set background color
//         wantsLayer = true
//         layer?.backgroundColor = NSColor.systemBlue.cgColor

//         // Add and center the button
//         addSubview(centerButton)
//         NSLayoutConstraint.activate([
//             centerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
//             centerButton.centerYAnchor.constraint(equalTo: centerYAnchor),
//         ])

//         self.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(Self.drag(_:))))
//     }

//     @objc
//     func drag(_ gesture: NSPanGestureRecognizer) {
//         let t = gesture.translation(in: nil)
//         gesture.setTranslation(.zero, in: nil)
//         self.emitter.emit(.dragGesture(.init(phase: .init(gestureRecognizerState: gesture.state), dx: t.x, dy: -t.y)))
//     }

//     // Ensure the view naturally sizes to 200×200
//     public override var intrinsicContentSize: NSSize {
//         return NSSize(width: 200, height: 200)
//     }

//     // MARK: - Actions

//     @objc private func handleButtonPress(_ sender: NSButton) {
//         print("Button pressed!")
//     }
// }

// extension CanvasAppKitView {
//     fileprivate struct Preview: NSViewRepresentable {
//         func makeNSView(context: Context) -> some NSView {
//             CanvasAppKitView(viewport: .init())
//         }

//         func updateNSView(_ nsView: NSViewType, context: Context) {

//         }
//     }
// }

// #Preview {
//     VStack {
//         CanvasAppKitView.Preview()
//     }
//     .padding(10)
// }

#endif
