import Foundation

enum Keyword: String {
    case title = "TITLE"
    case lut1DSize = "LUT_1D_SIZE"
    case lut3DSize = "LUT_3D_SIZE"
    case domainMin = "DOMAIN_MIN"
    case domainMax = "DOMAIN_MAX"
}

enum Token: Equatable {
    case text(String)
    case keyword(Keyword)
    case number(Float32)
    case comment
}

public enum TokenizerError: Error {
    case parseTextError
    case parseKeywordError(String?)
    case parseNumberError
    case unexpected(Character)
}

func tokenize(line: String) throws(TokenizerError) -> [Token] {
    var tokens = [Token]()

    var scanner = Scanner(line)

    if scanner.peek() == "#" {
        return [.comment]
    }

    while let ch = scanner.next() {
        if ch.isLetter {
            if let text = scanner.take(while: { ch in !ch.isWhitespace }) {
                if let kw = Keyword(rawValue: String(text)) {
                    tokens.append(.keyword(kw))
                } else {
                    throw .parseKeywordError(String(text))
                }
            } else {
                throw .parseKeywordError(nil)
            }

        } else if ch.isNumber || ch == "." {
            if let text = scanner.take(while: { ch in ch.isNumber || ch == "." }) {
                if let num = Float32(text) {
                    tokens.append(.number(num))
                } else {
                    throw .parseNumberError
                }
            } else {
                throw .parseNumberError
            }
        } else if ch == "\"" {
            if scanner.next() == nil {
                throw .parseTextError
            }
            if let text = scanner.take(noEndOfStringWhile: { ch in ch != "\"" }) {
                _ = scanner.next()
                tokens.append(.text(String(text)))
            } else {
                throw .parseTextError
            }
        } else if !ch.isWhitespace {
            throw .unexpected(ch)
        }
    }

    return tokens
}
