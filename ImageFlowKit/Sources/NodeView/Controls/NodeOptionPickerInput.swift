import Backend
import Design
import Helpers
import Logging
import SwiftUI
import Values
import XKit

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeOptionPickerInput: XViewEx, NodeControl {
    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var onEvent: ((NodeControlEvent) -> ())?

    #if os(iOS)
    var tint: XColor = .tintColor {
        didSet {
            self.pickerView.tintColor = self.tint
        }
    }
    #else
    var tint: XColor = .systemBlue
    #endif

    var isEditable: Bool { didSet { self.pickerView.isEnabled = self.isEditable } }
    var context: NodeControlContext = .init()

    private var options: [ValueSemantics.IntegerSemantics.PickerOption]

    #if os(macOS)
    lazy var pickerView: NSPopUpButton = {
        let picker = NSPopUpButton()
        picker.title = ""
        picker.pullsDown = false
        picker.target = self
        picker.action = #selector(Self.pickerHandler)
        for option in options {
            let item = NSMenuItem(title: option.title, action: nil, keyEquivalent: "")
            item.tag = option.value
            picker.menu?.addItem(item)
        }
        picker.selectItem(withTag: self.value.int)
        picker.isEnabled = self.isEditable
        return picker
    }()

    @objc
    func pickerHandler() {
        self.setValue(newValue: .int(self.pickerView.selectedTag()), oldValue: nil, registerUndo: true)
        self.emit(.sizeDidChange)
    }

    func update() {
        self.pickerView.selectItem(withTag: self.value.int)
        self.emit(.sizeDidChange)
    }

    #endif

    #if os(iOS)

    var pickerTitle: String {
        self.options.first(where: { $0.value == self.value.int }).map({ $0.title }) ?? ""
    }

    lazy var pickerView: UIButton = {
        let button = UIButton(type: .system)
        button.menu = UIMenu(
            title: "",
            options: [.singleSelection],
            children: [
                UIDeferredMenuElement.uncached { [weak self] completion in
                    guard let self else {
                        completion([])
                        return
                    }
                    completion(
                        self.options.map { option in
                            UIAction(
                                title: option.title,
                                state: self.value.int == option.value ? .on : .off,
                                handler: { [weak self] _ in
                                    self?.pickerHandler(option.value)
                                }
                            )
                        }
                    )
                }
            ]
        )
        button.showsMenuAsPrimaryAction = true
        button.setTitle(self.pickerTitle, for: .normal)
        button.configuration = .borderless()
        button.setImage(.init(systemName: "chevron.up.chevron.down"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(scale: .small), forImageIn: .normal)
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 4
        button.tintColor = self.tint
        return button
    }()

    func update() {
        self.updatePickerTitle()
    }

    func pickerHandler(_ choice: Int) {
        self.setValue(newValue: .int(choice), registerUndo: true)
    }

    func updatePickerTitle() {
        self.pickerView.setTitle(self.pickerTitle, for: .normal)
        self.setNeedsLayout()
        self.emit(.sizeDidChange)
    }

    #endif

    init(
        _ value: Value,
        options: [ValueSemantics.IntegerSemantics.PickerOption],
        isEditable: Bool = true
    ) {
        self.value = value
        self.options = options
        self.isEditable = isEditable

        super.init(frame: .zero)

        self.addSubview(self.pickerView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        self.pickerView.intrinsicContentSize
    }

    override func layout() {
        super.layout()

        self.pickerView.frame.origin = .zero
        self.pickerView.frame.size = self.pickerView.intrinsicContentSize
    }
}

extension ValueSemantics.IntegerSemantics.PickerOption {
    var title: String {
        self.label ?? "\(self.value)"
    }
}

extension NodeOptionPickerInput {
    struct Preview: XViewRepresentable {
        @Binding var value: Value
        func makeView(context: Context) -> NodeOptionPickerInput {
            let view = NodeOptionPickerInput(
                self.value,
                options: [
                    .init(label: "Zero", value: 0),
                    .init(label: "One", value: 1),
                    .init(label: "Two", value: 2),
                    .init(label: "Three", value: 3),
                ]
            )
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value):
                    self.value = value
                case .sizeDidChange:
                    break
                case .keyboardWillShow:
                    break
                case .statusBarMessage:
                    break
                }
            }
            return view
        }

        func updateView(_ view: NodeOptionPickerInput, context: Context) {
            if view.value != self.value {
                view.value = self.value
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .int(1)
    VStack {
        NodeOptionPickerInput.Preview(value: $value)
            .border(.red)
        Text("value: \(value.int)")
        Picker(
            "",
            selection: .init(
                get: {
                    value.int
                },
                set: { value = .int($0) }
            )
        ) {
            Text("Zero").tag(0)
            Text("One").tag(1)
            Text("Two").tag(2)
            Text("Three").tag(3)
        }
    }
    .frame(width: 500, height: 500)
    .background { Colors.cardBackground.color }
}
