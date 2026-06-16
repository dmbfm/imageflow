import Helpers

struct InspectorContext: With {
    var onNodeTypePickItem: ((String) -> ())?
    var onPortClick: (() -> ())?
    var onRestoreButtonClick: (() -> ())?
}
