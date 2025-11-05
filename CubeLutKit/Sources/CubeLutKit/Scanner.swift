import Foundation

struct Scanner {
    var str: String
    var cursor: String.Index
    var mark: String.Index?

    init(_ str: String) {
        self.str = str
        self.cursor = str.startIndex
    }

    mutating func next() -> Character? {
        if self.str.indices.contains(self.cursor) {
            let ch = self.str[self.cursor]
            self.cursor = self.str.index(after: self.cursor)
            return ch
        }

        return nil
    }

    mutating func peek() -> Character? {
        if self.str.indices.contains(self.cursor) {
            return self.str[self.cursor]
        }

        return nil
    }

    mutating func take(while predicate: (Character) -> Bool) -> Substring? {
        let start = self.str.index(before: self.cursor)

        if !self.str.indices.contains(start) {
            return nil
        }

        while let ch = self.peek() {
            if !predicate(ch) { break }
            _ = self.next()
        }

        let result = self.str[start..<self.cursor]
        return result
    }

    mutating func take(noEndOfStringWhile predicate: (Character) -> Bool) -> Substring? {
        let start = self.str.index(before: self.cursor)

        if !self.str.indices.contains(start) {
            return nil
        }

        while true {
            if let ch = self.peek() {
                if !predicate(ch) { break }
                _ = self.next()
            } else {
                return nil
            }
        }

        let result = self.str[start..<self.cursor]
        return result
    }
}

