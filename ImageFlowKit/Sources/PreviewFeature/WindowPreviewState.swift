enum WindowPreviewState {
    case open(WindowPreviewWindowController)
    case closed(WindowPreviewCache)

    var controller: WindowPreviewWindowController? {
        switch self {
        case .open(let controller): controller
        default: nil
        }
    }

    var cache: WindowPreviewCache? {
        switch self {
        case .closed(let cache): cache
        case .open: nil
        }
    }
}
