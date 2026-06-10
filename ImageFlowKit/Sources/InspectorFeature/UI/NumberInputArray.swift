import Combine
import ComponentKit
import Helpers
import SwiftUI
import XKit

fileprivate typealias HStack = ComponentKit.HStack
fileprivate typealias VStack = ComponentKit.VStack

extension XView {
    func border(_ color: XColor? = nil) -> Self {
        self.withLayer({
            $0.borderWidth = 1
            $0.borderColor = color?.cgColor ?? .red
        })
        return self
    }
}

final class NumberInputArray: XView, WithRef, Rx {

    public var stackView: ComponentKit::VStack!

    var cancellables: Set<AnyCancellable> = []

    var label: ComponentKit::Label!

    init(values: [(String, Double)]) {
        super.init(frame: .zero)

        self.stackView = VStack(
            alignment: .fill,
            views: values.map({ (label, value) in
                HStack(
                    alignment: .center,
                    views: [
                        Label(label).storeRef(self, \.label),
                        Label(label),
                        NumberInput(value),
                    ]
                )
            })
        ).with(\.translatesAutoresizingMaskIntoConstraints, false)

        print("label: \(self.label)")

        self.addSubview(self.stackView)
        NSLayoutConstraint.activateConstraint(self.stackView, toFill: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate struct PreviewView: XViewRepresentable {
    func makeView(context: Context) -> some NSView {
        NumberInputArray(values: [
            ("x", 1.0),
            ("y", 2.0),
            ("zed", 4.0),
        ])
    }

    func updateView(_ view: ViewType, context: Context) {

    }
}

#Preview {
    SwiftUI::VStack {
        PreviewView()
            .frame(width: 320)
            .fixedSize()
            .padding()
    }
}
