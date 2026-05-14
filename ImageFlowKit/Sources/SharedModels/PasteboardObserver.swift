import Helpers
import SwiftUI
import UniformTypeIdentifiers

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
        self.canPaste = UIPasteboard.general.imageFlowCanvasCanPaste
        NotificationCenter.default.addObserver(
            forName: UIPasteboard.changedNotification,
            object: UIPasteboard.general,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.canPaste = UIPasteboard.general.imageFlowCanvasCanPaste
                self?.emitter.emit(())
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.canPaste = UIPasteboard.general.imageFlowCanvasCanPaste
                    self?.emitter.emit(())
                }
            }
        )
        #endif

        #if os(macOS)
        self.canPaste = NSPasteboard.general.imageFlowCanvasCanPaste
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.canPaste = NSPasteboard.general.imageFlowCanvasCanPaste
            }
        }
        #endif
    }
}

#if os(macOS)
extension NSPasteboard {
    public var imageFlowCanvasCanPaste: Bool {
        self.canReadObject(forClasses: [FlowPasteboardItem.self])
            || self.canReadItem(withDataConformingToTypes: [
                "public.tiff", "public.png",
            ])
    }
}
#endif

#if os(iOS)
extension UIPasteboard {
    public var imageFlowCanvasCanPaste: Bool {
        self.contains(pasteboardTypes: [
            UTType.imageFlowNode.identifier,
            UTType.tiff.identifier,
            UTType.png.identifier,
            "public.avif",
        ])
    }
}
#endif
