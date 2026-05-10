import CardStage
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
        case toggleLock
    }

    enum Effect {
        case loadImage(OutputPortLocation)
    }

    struct StateTransition {
        var newState: State
        var effect: Effect?

        var pair: (State, Effect?) {
            (self.newState, self.effect)
        }
    }

    struct State: Equatable, With {

        var availableLocations: Set<PreviewLocation> = []
        var contentState: PreviewContentState = .nothing
        var anchor: CardStageAnchor = .bottomRight
        var dockLocation: CardDockLocation? = nil

        var location: OutputPortLocation? {
            get { self.contentState.location }
            set { self.contentState.location = newValue }
        }

        var locked: Bool {
            get { self.contentState.locked }
            set { self.contentState.locked = newValue }
        }

        var image: CIImage? {
            self.contentState.image
        }

        var content: PreviewContentState.Content? {
            get { self.contentState.content }
            set { self.contentState.content = newValue }
        }

        enum PreviewContentState: Equatable, With, CustomStringConvertible {
            case nothing
            case something(locked: Bool, location: OutputPortLocation, content: Content)

            var description: String {
                switch self {
                case .nothing: "nothing"
                case .something(let locked, let loc, let content):
                    "something(locked: \(locked), loc: \(loc), content: \(content))"
                }
            }

            enum Content: Equatable, With, CustomStringConvertible {
                case loading(CIImage?)
                case loaded(CIImage)
                case error(String)

                var description: String {
                    switch self {
                    case .error(let message): "error: (\(message))"
                    case .loaded: "loaded"
                    case .loading: "loading"
                    }
                }
            }

            var locked: Bool {
                get {
                    switch self {
                    case .nothing: false
                    case .something(let locked, _, _): locked
                    }
                }
                set {
                    switch self {
                    case .nothing:
                        break
                    case .something(_, location: let location, content: let content):
                        self = .something(locked: newValue, location: location, content: content)
                    }
                }
            }

            var location: OutputPortLocation? {
                get {
                    switch self {
                    case .nothing: nil
                    case .something(_, let loc, _): loc
                    }
                }
                set {
                    if let newValue {
                        switch self {
                        case .nothing: break
                        case .something(locked: let locked, _, let content):
                            self = .something(locked: locked, location: newValue, content: content)
                        }
                    } else {
                        self = .nothing
                    }
                }
            }

            var content: Content? {
                get {
                    switch self {
                    case .nothing: nil
                    case .something(_, _, let content): content
                    }
                }
                set {
                    if let newValue {
                        switch self {
                        case .nothing: break
                        case .something(let locked, let location, _):
                            self = .something(locked: locked, location: location, content: newValue)
                        }
                    } else {
                        self = .nothing
                    }
                }
            }

            var image: CIImage? {
                switch self {
                case .something(_, _, content: .loading(let image)): image
                case .something(_, _, content: .loaded(let image)): image
                default: nil
                }
            }

        }

        func input(_ input: Input) -> StateTransition {
            switch input {
            case .imageLoaded(let loc, let image):
                self.imageLoaded(loc, image)
            case .previewLocations(let locs):
                self.previewLocations(locs)
            case .toggleLock:
                self.toggleLock()
            case .updatedImage(let loc):
                self.updatedImage(loc)
            }
        }

        func toggleLock() -> StateTransition {
            if self.locked {
                self.unlock()
            } else {
                self.lock()
            }
        }

        func unlock() -> StateTransition {
            switch self.contentState {
            case .nothing:
                return .init(newState: self)

            case .something(locked: false, _, _):
                return .init(newState: self)

            case .something(locked: true, location: let loc, _):
                if self.availableLocations.isEmpty {
                    return .init(newState: self.with(\.contentState, .nothing))
                } else if self.availableLocations.contains(where: { $0.location == loc }) {
                    return .init(
                        newState: self.with(\.locked, false)
                    )
                } else {
                    return self.with(\.locked, false).selectFirstAvailable()
                }
            }
        }

        func lock() -> StateTransition {
            return .init(newState: self.with(\.locked, true))
        }

        func selectFirstAvailable() -> StateTransition {
            if let first = self.availableLocations.first {
                return .init(
                    newState: self.with(
                        \.contentState,
                        .something(locked: self.locked, location: first.location, content: .loading(self.image))
                    ),
                    effect: .loadImage(first.location)
                )
            } else {
                return .init(newState: self.with(\.contentState, .nothing))
            }
        }

        func previewLocations(_ locations: Set<PreviewLocation>) -> StateTransition {
            let newState = self.with(\.availableLocations, locations)

            switch self.contentState {
            case .nothing:
                return newState.selectFirstAvailable()

            case .something(locked: true, _, _):
                return .init(newState: newState)

            case .something(locked: false, let location, _):
                if locations.contains(where: { $0.location == location }) {
                    return .init(newState: newState)
                } else {
                    return newState.selectFirstAvailable()
                }
            }
        }

        func imageLoaded(_ location: OutputPortLocation, _ image: CIImage) -> StateTransition {
            switch self.contentState {
            case .something(let locked, let location, .loading(_)):
                return .init(
                    newState: self.with(
                        \.contentState,
                        .something(locked: locked, location: location, content: .loaded(image))
                    )
                )
            default:
                return .init(newState: self)
            }
        }

        func updatedImage(_ location: OutputPortLocation) -> StateTransition {
            switch self.contentState {
            case .something(locked: let locked, location, _):
                return .init(
                    newState: self.with(
                        \.contentState,
                        .something(locked: locked, location: location, content: .loading(self.image))
                    ),
                    effect: .loadImage(location)
                )
            default:
                return .init(newState: self)
            }
        }
    }
}

extension PreviewFeature.State: CustomStringConvertible {
    var description: String {
        "======================================== \n"
            + "PreviewFeature.State:\n"
            + "  availableLocations: \(self.availableLocations)\n"
            + "  ----------\n"
            + "   contentState: \(self.contentState)\n"
            + "======================================== \n"
    }
}
