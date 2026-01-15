import SwiftUI

extension View {
    public func activeViewObject<V: AnyObject>(_ value: V?) -> some View {
        self.modifier(ActiveViewObjectModifier(value: value))
    }
}

struct ActiveViewObjectModifier<V: AnyObject>: ViewModifier {

    @Environment(\.appearsActive) var appearsActive
    @Environment(\.scenePhase) var scenePhase

    weak var value: V?

    init(value: V? = nil) {
        self.value = value
    }

    func store() {
        Task { @MainActor in
            ActiveViewObjectStorage.shared.set(self.value)
        }
    }

    func clear() {
        ActiveViewObjectStorage.shared.clear(V.self)
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
                switch self.scenePhase {
                case .active: self.store()
                default: self.clear()
                }
            }
    }
}

@propertyWrapper
@MainActor
public struct ActiveViewObject<V: AnyObject> {

    public init(_ v: V.Type) {}

    public var wrappedValue: V? {
        get {
            ActiveViewObjectStorage.shared.get(V.self)
        }

        set {
            ActiveViewObjectStorage.shared.set(newValue)
        }
    }
}

@Observable
@MainActor
class ActiveViewObjectStorage {

    var objects: [ObjectIdentifier: Ref] = [:]

    static let shared = ActiveViewObjectStorage()

    class Ref {
        weak var ref: AnyObject?

        init(ref: AnyObject? = nil) {
            self.ref = ref
        }
    }

    func set<V: AnyObject>(_ value: V?) {
        self.objects[ObjectIdentifier(V.self)] = .init(ref: value)
    }

    func clear<V: AnyObject>(_ ty: V.Type) {
        self.objects.removeValue(forKey: ObjectIdentifier(ty))
    }

    func get<V: AnyObject>(_ ty: V.Type) -> V? {
        if let value = self.objects[ObjectIdentifier(ty)], let value = value.ref {
            return value as? V
        } else {
            return nil
        }
    }
}
