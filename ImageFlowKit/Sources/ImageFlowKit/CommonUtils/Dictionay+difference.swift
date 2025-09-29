import Foundation

public extension Dictionary where Value: Equatable {
    func difference(from other: Self) -> [EntryChange] {
        var changes = [EntryChange]()
        for (k, v) in self {
            if let otherValue = other[k] {
                if otherValue != v {
                    changes.append(.modified(k, otherValue))
                }
            } else {
                changes.append(.removed(k))
            }
        }
        for (k, v) in other {
            if self[k] == nil {
                changes.append(.added(k, v))
            }
        }
        return changes
    }

    enum EntryChange {
        case added(Key, Value)
        case removed(Key)
        case modified(Key, Value)
    }
}

extension Dictionary.EntryChange: Equatable {
    public static func == (lhs: Dictionary.EntryChange, rhs: Dictionary.EntryChange) -> Bool {
        switch (lhs, rhs) {
        case let (.added(lk, lv), .added(rk, rv)):
            return lk == rk && lv == rv
        case let (.removed(lk), .removed(rk)):
            return lk == rk
        case let (.modified(lk, lv), .modified(rk, rv)):
            return lk == rk && lv == rv
        default:
            return false
        }
    }
}

extension Dictionary.EntryChange: Hashable where Key: Hashable, Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .added(k, v):
            hasher.combine("added")
            hasher.combine(k)
            hasher.combine(v)
        case let .removed(k):
            hasher.combine("removed")
            hasher.combine(k)
        case let .modified(k, v):
            hasher.combine("modified")
            hasher.combine(k)
            hasher.combine(v)
        }
    }
}
