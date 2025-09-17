#if canImport(AppKit)

import SwiftUI
import AppKit
import Combine
import Logging

struct MenuCommands: Commands {
    var body: some Commands {
        Group {
            FileCommands()
        }
    }
}

@Observable
class CanSaveBox {
    var canSave: Bool = false {
        didSet {
            log("box changed!!!!!!!!!!!!")
        }
    }
}

@Observable
class WindowBox {
    weak var window: NSWindow?
}

struct FileCommands: Commands {

    private let items = NSSharingService.sharingServices(forItems: [""])

    func new() {
        Task { @MainActor in
            NSApp.closeWindow(.welcome)
        }
        NSDocumentController.shared.newDocument(nil)
        // self.canSaveFlag.toggle()
    }

    func open() {
        Task { @MainActor in
            NSApp.closeWindow(.welcome)
        }
        NSDocumentController.shared.openDocument(nil)
    }

    func close() {
        NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
    }

    func save() {
        NSApp.sendAction(#selector(MenuActions.saveDocument(_:)), to: nil, from: nil)
    }

    func canSave() -> Bool {
        let id = NSApp.keyWindow?.identifier
        print("id ---> \(id)")
        return id == WindowID.document.identifier
    }

    @State var keyWindowCancellable: AnyCancellable?
    // @State var canSaveFlag: Bool = false
    // @StateObject var canSaveFlag =

    var canSaveBox: CanSaveBox

    init() {
        log("init")
        let box = CanSaveBox()
        self.canSaveBox = box
        let cancellable = NSApp.publisher(for: \.keyWindow).receive(on: RunLoop.main).sink { window in
            log("keyWindow: \(keyWindow)")
            box.canSave = window?.identifier == WindowID.document.identifier
        }
        log("\(cancellable)")
        self._keyWindowCancellable = .init(initialValue: cancellable)
    }

    @ViewBuilder
    func button(_ name: String, _ icon: String? = nil, _ action: @escaping () -> ()) -> some View {
        if #available(macOS 26, *) {
            Button(action: action) {
                if let icon {
                    Label(name, systemImage: icon)
                } else {
                    Text(name)
                }
            }
        } else {
            Button(action: action) {
                Text(name)
            }
        }
    }

    var body: some Commands {
        Group {
            CommandGroup(replacing: .newItem) {
                Group {
                    self.button("New", "plus") {
                        self.new()
                    }
                    .keyboardShortcut("n")

                    self.button("Open...", "arrow.up.right") { self.open() }
                        .keyboardShortcut("o", modifiers: [.command])

                    Menu {
                        self.button("Clear Menu") {}
                            .disabled(true)
                    } label: {
                        Text("Open Recent")
                    }

                }
            }

            CommandGroup(replacing: .saveItem) {
                Group {
                    self.button("Close", "xmark") { self.close() }
                        .keyboardShortcut("w")

                    self.button("Save", "square.and.arrow.down", { self.save() })
                        .keyboardShortcut("s")
                        .disabled(!self.canSaveBox.canSave)

                    self.button("Duplicate", "plus.square.on.square", {})
                        .keyboardShortcut("s", modifiers: [.command, .shift])
                        .disabled(true)

                    self.button("Rename...", "pencil") {}
                        .disabled(true)

                    self.button("Move To...", "folder") {}
                        .disabled(true)

                    Menu {

                    } label: {
                        Text("Revert To")
                    }
                }
            }
        }
    }
}

@objc protocol MenuActions {
    func saveDocument(_ sender: AnyObject)
    func saveDocumentAs(_ sender: AnyObject)
    func redo(_ sender: AnyObject)
    func undo(_ sender: AnyObject)
    func cut(_ sender: AnyObject)
    func copy(_ sender: AnyObject)
    func paste(_ sender: AnyObject)
}

#endif
