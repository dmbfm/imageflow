import Backend
import Helpers
import Logging
import Photos
import SwiftUI
import Values

#if os(macOS)
typealias MainContentView = MainContentViewMacOS
#endif

#if os(iOS)
typealias MainContentView = MainContentViewIPadOS
#endif
