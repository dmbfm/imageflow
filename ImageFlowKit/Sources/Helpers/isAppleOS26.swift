public func isAppleOS26() -> Bool {
    #if os(macOS)
    if #available(macOS 26, *) {
        true
    } else {
        false
    }
    #elseif os(iOS)
    if #available(macOS26 , *) {
        true
    } else {
        false
    }
    #else
    #error("Not supported")
    #endif
}
