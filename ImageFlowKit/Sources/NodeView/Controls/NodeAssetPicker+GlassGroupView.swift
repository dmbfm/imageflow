#if canImport(UIKit)

import Helpers
import UIKit
import SwiftUI

extension NodeAssetPicker {
    final class GlassGroupView: UIView, NodeAssetPickerInnerView {

        var onButtonClick: (() -> ())?
        var onRemoveButtonClick: (() -> ())?

        var vm: NodeAssetPickerInnerViewModel {
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
            btn.configuration?.titleLineBreakMode = .byTruncatingTail
            btn.titleLabel?.font = .systemFont(ofSize: 8)
            btn.configuration?.baseForegroundColor = .systemOrange
            btn.addTarget(self, action: #selector(Self.buttonHandler), for: .touchUpInside)
            btn.toolTip = self.vm.label
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

        init(vm: NodeAssetPickerInnerViewModel) {
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
            self.buttonView.toolTip = self.vm.label
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
            self.containerView.frame = .init(origin: .zero, size: self.bounds.size)
            self.buttonView.frame = .init(
                origin: .zero,
                size:
                    .init(
                        width: self.bounds.width - self.removeButtonView.intrinsicContentSize.width,
                        height: self.buttonView.intrinsicContentSize.height
                    )
            )
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

            func updateUIView(_ uiView: NodeAssetPicker.GlassGroupView, context: Context) {

            }

            func sizeThatFits(
                _ proposal: ProposedViewSize,
                uiView: NodeAssetPicker.GlassGroupView,
                context: Context
            ) -> CGSize? {
                uiView.intrinsicContentSize
            }
        }
    }
}

#Preview {
    VStack {
        //        NodeAssetPicker.GlassGroupView.Preview()
    }
    .padding(100)
}

#endif
