#if canImport(UIKit)

import Helpers
import UIKit
import SwiftUI

extension NodeImageInput {
    final class GlassGroupView: UIView, InnerView {

        var onButtonClick: (() -> ())?
        var onRemoveButtonClick: (() -> ())?

        var vm: ViewModel {
            didSet {
                self.update()
            }
        }

        lazy var containerView: UIView = {
            let effectView = UIGlassContainerEffect()
            effectView.spacing = 12
            let containerView = UIVisualEffectView(effect: effectView)
            containerView.contentView.addSubview(buttonView)
            containerView.contentView.addSubview(removeButtonView)
            return containerView
        }()

        lazy var buttonView: UIButton = {
            let btn = UIButton(configuration: .glass())
            btn.setTitle(self.vm.label, for: .normal)
            btn.configuration?.buttonSize = .mini
            btn.titleLabel?.font = .systemFont(ofSize: 8)
            btn.configuration?.baseForegroundColor = .systemOrange
            btn.addTarget(self, action: #selector(Self.buttonHandler), for: .touchUpInside)
            return btn
        }()

        @objc
        func buttonHandler() {
            self.onButtonClick?()
        }

        @objc
        func removeButtonHandler() {
            self.onRemoveButtonClick?()
        }

        lazy var removeButtonView: UIButton = {
            let btn = UIButton(configuration: .glass())
            btn.configuration?.buttonSize = .mini
            btn.setImage(
                UIImage(
                    systemName: "xmark",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
                )?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal),
                for: .normal
            )
            btn.addTarget(self, action: #selector(Self.removeButtonHandler), for: .touchUpInside)
            return btn
        }()

        init(vm: ViewModel) {
            self.vm = vm

            super.init(frame: .zero)

            self.addSubview(self.containerView)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }

        func update() {
            self.buttonView.setTitle(self.vm.label, for: .normal)
            self.removeButtonView.isHidden = !self.vm.showRemoveButton
            self.setNeedsLayout()
        }

        override var intrinsicContentSize: CGSize {
            let btnSize = self.buttonView.intrinsicContentSize
            let removeBtnSize = self.removeButtonView.intrinsicContentSize
            return btnSize.minMax(removeBtnSize, width: .sum, height: .max)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            self.containerView.frame = .init(origin: .zero, size: self.intrinsicContentSize)
            self.buttonView.frame = .init(origin: .zero, size: self.buttonView.intrinsicContentSize)
            self.removeButtonView.frame = .init(
                origin: .init(x: self.buttonView.frame.maxX, y: 0),
                size: self.removeButtonView.intrinsicContentSize
            )

            Layout.align(
                views: [
                    self.buttonView, self.removeButtonView,
                ],
                alignment: .verticalCenter,
                guide: .constant(self.bounds.midY)
            )
        }

        fileprivate struct Preview: UIViewRepresentable {
            func makeUIView(context: Context) -> GlassGroupView {
                .init(vm: .init(label: "some_file.png", showRemoveButton: true))
            }

            func updateUIView(_ uiView: NodeImageInput.GlassGroupView, context: Context) {

            }

            func sizeThatFits(
                _ proposal: ProposedViewSize,
                uiView: NodeImageInput.GlassGroupView,
                context: Context
            ) -> CGSize? {
                uiView.intrinsicContentSize
            }
        }
    }
}

#Preview {
    VStack {
        NodeImageInput.GlassGroupView.Preview()
    }
    .padding(100)
}

#endif
