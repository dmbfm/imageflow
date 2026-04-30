#if canImport(AppKit)

import AppKit
import Helpers
import SwiftUI

struct CardStage {
    struct Model: Equatable {
        var alignment: Alignment
        var size: CGSize
        var insets: Insets
        // var state: State

        init(
            alignment: Alignment = .bottomRight,
            size: CGSize = .init(width: 250, height: 250),
            insets: Insets = .init(left: 10, right: 10, top: 10, bottom: 10),
        ) {
            self.alignment = alignment
            self.size = size
            self.insets = insets
        }
    }

    enum Alignment: String, Equatable, CaseIterable, Identifiable {
        var id: Self { self }
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    struct Insets: Equatable {
        var left: CGFloat
        var right: CGFloat
        var top: CGFloat
        var bottom: CGFloat
    }
}

extension CardStage {
    final class Controller: NSViewController, MainViewDelegate {

        var model: Model {
            didSet {
                if self.model != oldValue {
                    self.stageView.upadateModel(self.model)
                }
            }
        }

        var stageView: MainView!
        var cardView: CardView!

        init(_ model: Model) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
            self.view.clipsToBounds = false
        }

        required init?(coder: NSCoder) {
            nil
        }

        override func loadView() {
            self.stageView = .init()
            self.cardView = self.stageView.cardView
            self.stageView.delegate = self
            self.view = self.stageView
        }

        override func viewDidLoad() {
            self.stageView.upadateModel(self.model)
        }

        func mainViewDidChangeAlignment(_ alignment: CardStage.Alignment) {
            self.model.alignment = alignment
        }
    }
}

extension CardStage {

    protocol MainViewDelegate: AnyObject {
        func mainViewDidChangeAlignment(_ alignment: Alignment)
    }

    final class MainView: PlatformCommonView {

        var cardView: CardView
        weak var delegate: MainViewDelegate?

        private var model: Model = .init()

        var state: State = .idle {
            didSet {
                if self.state != oldValue {
                    self.setNeedsLayout()
                }
            }
        }

        enum State: Equatable {
            case idle
            case dragging(offset: CGSize)
            case animating(AnimationState)
        }

        struct AnimationState: Equatable {
        }

        init() {
            self.cardView = .init()

            super.init(frame: .zero)

            self.addSubview(self.cardView)

            let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
            self.cardView.addGestureRecognizer(panGesture)
        }

        required init?(coder: NSCoder) {
            nil
        }

        @objc func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
            // print("\(gesture.translation(in: nil))")
            // logger.debug("gesture: \("\(gesture.translation(in: nil))")")

            let t = gesture.translation(in: nil)

            switch gesture.state {
            case .possible:
                break
            case .began:
                self.state = .dragging(offset: .zero)
            case .changed:
                self.state = .dragging(offset: .init(width: t.x, height: -t.y))
            case .ended, .cancelled, .failed:
                let newAlignment = self.closestAnchorAlignment
                print("newAlignment: \(newAlignment)")
                if newAlignment != self.model.alignment {
                    self.model.alignment = self.closestAnchorAlignment
                    self.delegate?.mainViewDidChangeAlignment(self.model.alignment)
                }
                self.cardView.animator().frame.origin = self.anchorPoint
                self.state = .idle
            @unknown default:
                break
            }
        }

        func upadateModel(_ model: Model) {
            if model != self.model {
                self.model = model
                self.needsLayout = true
            }
        }

        var offset: CGPoint {
            switch self.state {
            case .dragging(let offset): offset.cgPoint
            default: .zero
            }
        }

        var closestAnchorAlignment: Alignment {
            let pos = self.anchorPoint + self.offset
            var dist: CGFloat = .greatestFiniteMagnitude
            var closest: Alignment = self.model.alignment

            for (anchor, point) in self.anchorPoints {
                let d = point.distance(to: pos)
                if d < dist {
                    closest = anchor
                    dist = d
                }
            }

            return closest
        }

        var anchorPoints: [Alignment: CGPoint] {
            let size = model.size
            let insets = model.insets

            let minX = insets.left
            let minY = insets.top
            let maxX = self.bounds.width - insets.right - size.width
            let maxY = self.bounds.height - insets.top - size.height

            let result: [Alignment: CGPoint] = [
                .topLeft: .init(x: minX, y: minY),
                .topRight: .init(x: maxX, y: minY),
                .bottomLeft: .init(x: minX, y: maxY),
                .bottomRight: .init(x: maxX, y: maxY),
            ]
            return result
        }

        var anchorPoint: CGPoint {
            self.anchorPoints[self.model.alignment]!
        }

        override func layout() {
            super.layout()

            let size = model.size

            let offset: CGSize =
                switch self.state {
                case let .dragging(offset): offset
                default:
                    .zero
                }

            self.cardView.frame.size = size
            self.cardView.frame.origin = self.anchorPoint + offset.cgPoint

        }
    }
}

extension CardStage {
    final class CardView: PlatformCommonView {
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.wantsLayer = true
            self.layer?.backgroundColor = NSColor.systemMint.cgColor
            self.layer?.cornerRadius = 10
            self.layer?.cornerCurve = .continuous

            self.shadow = .init()

            self.layer?.shadowColor = CGColor(gray: 0.5, alpha: 0.5)
            self.layer?.shadowRadius = 8
            self.layer?.shadowOpacity = 1.0
            self.layer?.shadowOffset = .zero
            self.layer?.masksToBounds = false

            self.clipsToBounds = false
        }

        required init?(coder: NSCoder) {
            nil
        }
    }
}

extension CardStage {
    struct PreviewRepresentable: NSViewControllerRepresentable {
        let model: Model
        func makeNSViewController(context: Context) -> CardStage.Controller {
            .init(self.model)
        }

        func updateNSViewController(_ vc: CardStage.Controller, context: Context) {
            if vc.model != self.model {
                vc.model = self.model
            }
        }
    }
}

#Preview {
    @Previewable @State var model: CardStage.Model = .init()

    VStack {
        CardStage.PreviewRepresentable(model: model)
            .frame(width: 800, height: 600)
            .padding()
            .border(.gray)

        Divider()

        VStack {
            Picker("", selection: $model.alignment) {
                ForEach(CardStage.Alignment.allCases) { item in
                    Text("\(item.rawValue)").tag(item)
                }
            }
        }
        .padding()
    }
}

#endif
