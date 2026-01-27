import SwiftUI
import Logging
import UniformTypeIdentifiers
import Helpers

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

@MainActor
@Observable
public final class PasteboardObserver {
    public var canPaste: Bool = false

    #if os(macOS)
    var timer: Timer?
    #endif

    public static let shared: PasteboardObserver = .init()

    public var emitter: EventEmitter<()> = .init()
    
    public init() {
        #if os(iOS)
        self.canPaste = UIPasteboard.general.contains(pasteboardTypes: [UTType.flowNode.identifier])
        NotificationCenter.default.addObserver(forName: UIPasteboard.changedNotification, object: UIPasteboard.general, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.canPaste = UIPasteboard.general.contains(pasteboardTypes: [UTType.flowNode.identifier])
                self?.emitter.emit(())
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main, using: { [weak self] _ in
            MainActor.assumeIsolated {
                self?.canPaste = UIPasteboard.general.contains(pasteboardTypes: [UTType.flowNode.identifier])
                self?.emitter.emit(())
            }
        })
        #endif
        
        #if os(macOS)
        self.canPaste = NSPasteboard.general.canReadObject(forClasses: [FlowPasteboardItem.self])
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] t in
            Task { @MainActor in
                self?.canPaste = NSPasteboard.general.canReadObject(forClasses: [FlowPasteboardItem.self])
            }
        }
        #endif
    }
}
