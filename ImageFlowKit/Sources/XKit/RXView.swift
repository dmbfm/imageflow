import Combine
import Helpers

public final class RXView: XView, Rx, WithRef {
    public var cancellables: Set<AnyCancellable> = []
}
