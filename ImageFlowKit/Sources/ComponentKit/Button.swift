import Combine
import Helpers
import SwiftUI
import XKit

public final class Button: XButton, Rx, WithRef {

    public var onClick: (() -> ())?

    public var cancellables: Set<AnyCancellable> = []

    public var publisher: PassthroughSubject<(), Never> = .init()

    public init(
        _ label: String,
        image: XImage? = nil,
        buttonSize: XButtonSize = .regular,
        tint: XColor? = nil,
        onClick: (() -> ())? = nil
    ) {
        self.onClick = onClick
        super.init(frame: .zero)
        self.title = label
        self.target = self
        self.action = #selector(Self.click)
        self.controlSize = buttonSize
        self.image = image
        self.contentTintColor = tint
        self.imagePosition = .imageLeading
        self.bezelStyle = .push
    }

    public convenience init(
        _ label: String,
        systemSymbolName: String,
        buttonSize: XButtonSize = .regular,
        tint: XColor? = nil,
        onClick: (() -> ())? = nil
    ) {
        self.init(
            label,
            image: XImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil),
            buttonSize: buttonSize,
            tint: tint,
            onClick: onClick
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func click() {
        self.onClick?()
        self.publisher.send(())
    }
}

#Preview {
    Button(
        "Hello!",
        image: XImage(systemSymbolName: "trash", accessibilityDescription: nil)
    ) { print(", World!") }
}
