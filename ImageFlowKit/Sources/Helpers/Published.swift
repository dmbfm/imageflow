import Combine
import Foundation

@propertyWrapper
public struct PublishedEx<Value> {

    private var publisher: CurrentValueSubject<Value, Never>

    @available(*, unavailable)
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    public var projectedValue: CurrentValueSubject<Value, Never> {
        self.publisher
    }

    public static subscript<EnclosingSelf: AnyObject>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, PublishedEx<Value>>,
    ) -> Value {
        get {
            object[keyPath: storageKeyPath].projectedValue.value
        }
        set {
            object[keyPath: storageKeyPath].projectedValue.send(newValue)
        }
    }

    public init(wrappedValue value: Value) {
        self.publisher = .init(value)
    }
}
