public extension Array where Element == Bool {
    func any() -> Bool {
        for x in self {
            if x {
                return true
            }
        }

        return false
    }

    func all() -> Bool {
        for x in self {
            if !x {
                return false
            }
        }

        return true
    }
}

public extension Array {
    func any(where clause: (Element) -> Bool) -> Bool {
        for x in self {
            if clause(x) {
                return true
            }
        }

        return false
    }

    func all(where clause: (Element) -> Bool) -> Bool {
        for x in self {
            if !clause(x) {
                return false
            }
        }

        return true
    }
}
