import Foundation
import UniformTypeIdentifiers

extension UTType {
    var displayText: String {
        self.description
    }
}

extension MainContentView {

    enum UserError: LocalizedError {
        case importFilesNotSupported(Set<UTType>)

        var errorDescription: String? {
            switch self {
            case .importFilesNotSupported(let types):
                {
                    if types.isEmpty {
                        "Import failed: unsupported file type"
                    } else if types.count == 1 {
                        "Import failed: unsupported file type: \(types.first!.displayText)"
                    } else {
                        "The follwing file types are not supported: \(types.map({ $0.displayText }).joined(separator: ", "))"
                    }
                }()
            }
        }
    }
}
