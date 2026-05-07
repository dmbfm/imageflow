import CoreImage
import Foundation
import Helpers
import SharedModels

extension PreviewFeature {

    struct PreviewLocation: Hashable {
        var name: String
        var location: OutputPortLocation
    }

    enum Input {
        case updatedImage(OutputPortLocation)
        case previewLocations(Set<PreviewLocation>)
        case imageLoaded(OutputPortLocation, CIImage)
    }

    enum Effect {
        case loadImage(OutputPortLocation)
    }

    enum State: Equatable, With {
        case nothing
        case loading(locked: Bool, location: OutputPortLocation, image: CIImage?)
        case loaded(locked: Bool, location: OutputPortLocation, image: CIImage)
        case error(locked: Bool, location: OutputPortLocation, message: String)

        var image: CIImage? {
            switch self {
            case .loaded(_, _, let image): image
            case .loading(_, _, let image): image
            default: nil
            }
        }

        var location: OutputPortLocation? {
            get {
                switch self {
                case .loading(_, let location, _),
                    .loaded(_, let location, _),
                    .error(_, let location, _):
                    location
                default:
                    nil
                }
            }
            set {
                guard let newValue else { return }
                switch self {
                case .nothing: break
                case .error(let a, _, let c): self = .error(locked: a, location: newValue, message: c)
                case .loaded(let a, _, let c): self = .loaded(locked: a, location: newValue, image: c)
                case .loading(let a, _, let c): self = .loading(locked: a, location: newValue, image: c)
                }
            }
        }

        var locked: Bool {
            get {
                switch self {
                case .nothing: false
                case .error(let locked, _, _), .loading(let locked, _, _), .loaded(let locked, _, _): locked
                }
            }

            set {
                switch self {
                case .nothing: break
                case .error(_, let b, let c): self = .error(locked: newValue, location: b, message: c)
                case .loading(_, let b, let c): self = .loading(locked: locked, location: b, image: c)
                case .loaded(_, let b, let c): self = .loaded(locked: locked, location: b, image: c)
                }
            }
        }

        func input(_ input: Input) -> (State, Effect?) {
            switch input {

            case .previewLocations([]):
                if !self.locked {
                    return (.nothing, nil)
                } else {
                    return (self, nil)
                }

            case .previewLocations(let locs):
                switch self {

                case .nothing, .error:
                    let loc = locs.first!.location
                    return (
                        .loading(locked: false, location: loc, image: nil), .loadImage(loc)
                    )

                case let .loading(locked, location, image):
                    if locs.contains(where: { $0.location == location }) || locked {
                        return (self, nil)
                    } else {
                        let loc = locs.first!.location
                        return (.loading(locked: locked, location: loc, image: image), .loadImage(loc))
                    }

                case let .loaded(locked, location, image):
                    if locs.contains(where: { $0.location == location }) || locked {
                        return (self, nil)
                    } else {
                        let loc = locs.first!.location
                        return (.loading(locked: locked, location: loc, image: image), .loadImage(loc))
                    }
                }

            case let .imageLoaded(loc, image):
                return (.loaded(locked: self.locked, location: loc, image: image), nil)

            case .updatedImage(let location):
                guard let current = self.location, current == location else { return (self, nil) }

                return (.loading(locked: self.locked, location: location, image: self.image), .loadImage(location))
            }
        }
    }
}

extension PreviewFeature.State: CustomStringConvertible {
    var description: String {
        "PreviewFeature.State:\n"
            + {
                switch self {
                case .nothing:
                    "  nothing"
                case let .error(locked, location, message):
                    "  error(\(locked), \(location), \(message))"
                case let .loading(locked, location, image):
                    " loading(\(locked), \(location), \(image, default: "nil")) "
                case let .loaded(locked, location, image):
                    " loaded(\(locked), \(location), \(image, default: "nil")) "
                }
            }()
    }
}
