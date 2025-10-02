import SwiftUI

#if canImport(AppKit)
typealias MainView = MainViewMac
#else
typealias MainView = MainViewIPad
#endif
