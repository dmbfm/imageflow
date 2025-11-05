import Foundation

struct TokenScanner {
    var tokens: [Token]
    var index: Int

    init(_ tokens: [Token]) {
        self.tokens = tokens
        self.index = 0
    }

    mutating func next() -> Token? {
        if self.tokens.indices.contains(self.index) {
            let result = self.tokens[self.index]
            self.index += 1
            return result
        }

        return nil
    }

    func peek() -> Token? {
        if self.tokens.indices.contains(self.index) {
            let result = self.tokens[self.index]
            return result
        }

        return nil
    }

    mutating func expectNumber() -> Float32? {
        switch self.peek() {
        case .number(let num):
            _ = self.next()
            return num
        default:
            return nil
        }
    }

    mutating func expectText() -> String? {
        switch self.peek() {
        case .text(let value):
            _ = self.next()
            return value
        default:
            return nil
        }
    }
}

