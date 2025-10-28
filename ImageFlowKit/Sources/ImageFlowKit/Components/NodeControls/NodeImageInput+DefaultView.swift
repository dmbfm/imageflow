#if canImport(AppKit)

import Helpers
import AppKit

extension NodeImageInput {
    final class DefaultView: PlatformCommonView, InnerView {

        var onButtonClick: (() -> ())?

        var onRemoveButtonClick: (() -> ())?

        var vm: ViewModel {
            didSet {
                self.update()
            }
        }

        let padding: CGFloat = 4

        lazy var buttonView: NSButton = {
            let button = NSButton(title: self.vm.label, target: nil, action: nil)
            button.target = self
            button.action = #selector(Self.buttonHandler)
            button.isBordered = false
            button.contentTintColor = .orange
            button.tintProminence = .secondary
            button.font = .systemFont(ofSize: 12)
            return button
        }()

        lazy var removeButtonView: NSButton = {
            let image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)!
                .withSymbolConfiguration(.init(pointSize: 12, weight: .regular))!
            let button = NSButton(image: image, target: nil, action: nil)
            button.target = self
            button.action = #selector(Self.removeButtonHandler)
            button.isHidden = true
            button.isBordered = false
            return button
        }()

        init(vm: ViewModel) {
            self.vm = vm

            super.init(frame: .zero)

            self.addSubview(self.buttonView)
            self.addSubview(self.removeButtonView)

            self.update()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }

        func update() {
            self.buttonView.title = self.vm.label
            self.removeButtonView.isHidden = !self.vm.showRemoveButton
            self.setNeedsLayout()
        }

        @objc
        func buttonHandler() {
            self.onButtonClick?()
        }

        @objc
        func removeButtonHandler() {
            self.onRemoveButtonClick?()
        }

        override var intrinsicContentSize: CGSize {
            let buttonSize = self.buttonView.intrinsicContentSize
            let xButtonSize = self.removeButtonView.intrinsicContentSize + .init(width: self.padding, height: 0)
            return buttonSize.minMax(xButtonSize, width: .sum, height: .max)
        }

        override func doLayout() {
            self.buttonView.frame.origin = .zero
            self.buttonView.frame.size = self.buttonView.intrinsicContentSize
            self.removeButtonView.frame.origin = .init(x: self.buttonView.frame.maxX + self.padding, y: 0)
            self.removeButtonView.frame.size = self.removeButtonView.intrinsicContentSize

            Layout.align(
                views: [self.buttonView, self.removeButtonView],
                alignment: .verticalCenter,
                guide: .constant(self.bounds.midY)
            )
        }
    }
}

#endif
