import Combine
import SwiftUI

extension View {
    /// Stores a object instance the Active View storage. Once in the Active
    /// View Storage, it can be accessed by other views (in fact, anywhere) by using the
    /// `@ActiveViewObject` property wrapper.
    ///
    /// It works similarly ot the `.focusedSceneValue` / `@FocusedValue` pair in
    /// SwiftUI. Sadly, the SwiftUI solution causes memory leaks, while our Active View
    /// Storage is guaranteed not to leak, since it stores only weak references.
    ///
    /// - Parameters:
    ///   - value: The object instance to be stored.
    ///   - key: An optional associated key. This is useful in cases where you have multiple
    ///          windows which can cause values of the same type and same key to be erased.
    ///   - useScenePhase: If `true`, use SwiftUI's `scenePhase` environment variable to set /
    ///                     clear storage entries. This can cause weird behavior on macOS in cases
    ///                     where `scenePhase` does not behave as expected, e.g., when you have a
    ///                     `NSWindow` that is launched outside of the SwiftUI scene.
    /// - Returns:
    public func activeViewObject<V: AnyObject>(_ value: V?, key: String = "", useScenePhase: Bool = true) -> some View {
        self.modifier(ActiveViewObjectModifier(value: value, key: key, useScenePhase: useScenePhase))
    }
}

struct ActiveViewObjectModifier<V: AnyObject>: ViewModifier {
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.scenePhase) var scenePhase

    weak var value: V?
    var key: String
    var useScenePhase: Bool

    init(
        value: V? = nil,
        key: String = "",
        useScenePhase: Bool = true
    ) {
        self.value = value
        self.key = key
        self.useScenePhase = useScenePhase
    }

    func store() {
        ActiveViewObjectStorage.shared.set(self.value, key: self.key)
    }

    func clear() {
        ActiveViewObjectStorage.shared.clear(V.self, key: self.key)
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                self.store()
            }
            .onDisappear {
                self.clear()
            }
            .onChange(of: self.appearsActive, initial: true) {
                if self.appearsActive {
                    self.store()
                } else {
                    self.clear()
                }
            }
            .onChange(of: self.scenePhase, initial: true) {
                if self.useScenePhase {
                    switch self.scenePhase {
                    case .active: self.store()
                    case .inactive: self.clear()
                    default: break
                    }
                }
            }
    }
}

@propertyWrapper
@MainActor
public struct ActiveViewObject<V: AnyObject> {

    public init(_ v: V.Type) {}

    public var wrappedValue: V? {
        ActiveViewObjectStorage.shared.get(V.self)
    }
}

@propertyWrapper
@MainActor
public struct ActiveViewObjectPublisher<V: AnyObject> {

    private var cancellables: Set<AnyCancellable> = []

    public var p = PassthroughSubject<(), Never>()

    public init(_ v: V.Type) {
        ActiveViewObjectStorage.shared.publisher.sink { [weak p = self.p] id in
            if id == ObjectIdentifier(v) {
                p?.send(())
            }
        }
        .store(in: &self.cancellables)
    }

    public var wrappedValue: V? {
        ActiveViewObjectStorage.shared.get(V.self)
    }

    public var projectedValue: PassthroughSubject<(), Never> {
        self.p
    }
}

@Observable
@MainActor
private class ActiveViewObjectStorage {

    var objects: [ObjectIdentifier: KeyedRefList] = [:]

    var publisher: PassthroughSubject<ObjectIdentifier, Never> = .init()

    static let shared = ActiveViewObjectStorage()

    func set<V: AnyObject>(_ value: V?, key: String = "") {
        let id = ObjectIdentifier(V.self)

        if self.objects[id] == nil {
            self.objects[id] = .init()
        }

        self.objects[id]?.push(.init(ref: value), key: key)
        self.publisher.send(id)
    }

    func clear<V: AnyObject>(_ ty: V.Type, key: String = "") {
        let id = ObjectIdentifier(V.self)

        if var list = self.objects[id] {
            list.remove(key: key)
            self.objects[id] = list

            if list.isEmpty {
                self.objects.removeValue(forKey: id)
            }

            self.publisher.send(id)
        }
    }

    func get<V: AnyObject>(_ ty: V.Type) -> V? {
        if let list = self.objects[ObjectIdentifier(V.self)], let ref = list.get()?.ref {
            if let value = ref as? V {
                return value
            }
            return ref as? V
        } else {
            return nil
        }

    }
}

struct KeyedRefList {
    var items: [KeyedRef] = []

    var isEmpty: Bool {
        self.items.isEmpty
    }

    mutating func push(_ ref: Ref, key: String) {
        for i in items.indices where items[i].key == key {
            self.items[i].ref = ref
            return
        }

        self.items.append(.init(key: key, ref: ref))
    }

    mutating func remove(key: String) {
        self.items.removeAll(where: { $0.key == key })
    }

    func get(key: String) -> Ref? {
        self.items.first(where: { $0.key == key })?.ref
    }

    func get() -> Ref? {
        self.items.last?.ref
    }
}

class Ref {
    weak var ref: AnyObject?

    init(ref: AnyObject? = nil) {
        self.ref = ref
    }
}

struct KeyedRef {
    var key: String
    var ref: Ref
}
