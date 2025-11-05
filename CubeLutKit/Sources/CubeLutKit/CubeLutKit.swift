import Foundation

public struct CubeLutInfo: Sendable, Equatable {
    public let title: String?
    public let domainMin: [Float32]
    public let domainMax: [Float32]
    public let dim: LutDim
}

public struct CubeLut: Sendable, Equatable {
    public let info: CubeLutInfo
    public let data: Data
}

public struct CubeLutArray: Sendable, Equatable {
    public let info: CubeLutInfo
    public let data: [Float32]
}

public enum LutDim: Sendable, Equatable {
    case one(Int)
    case three(Int)
}

extension CubeLut {
    public init(source: String) throws(CubeLutError) {
        let arr = try CubeLutArray(source: source)
        self.info = arr.info
        self.data = arr.data.withUnsafeBufferPointer { Data(buffer: $0) }
    }
}

extension CubeLutArray {
    public init(source: String) throws(CubeLutError) {

        var title: String? = nil
        var domainMin: [Float32] = .init(repeating: 0, count: 3)
        var domainMax: [Float32] = .init(repeating: 1, count: 3)
        var dim: LutDim? = nil
        var table: [Float32] = []

        for line in source.components(separatedBy: .newlines) {

            var toks: [Token]
            do {
                toks = try tokenize(line: line)
            } catch {
                throw .tokenizer(error)
            }

            if toks.isEmpty { continue }

            var scanner = TokenScanner(toks)

            switch scanner.next() {
            case .none:
                break
            case .comment:
                break
            case .keyword(let kw):
                switch kw {
                case .title:
                    if let text = scanner.expectText() {
                        title = text
                    } else {
                        throw .parseError(line)
                    }
                case .domainMax:
                    var arr = [Float32]()
                    while let num = scanner.expectNumber() {
                        arr.append(num)
                    }

                    if arr.count != 3 {
                        throw .parseError(line)
                    }

                    domainMax = arr
                case .domainMin:
                    var arr = [Float32]()
                    while let num = scanner.expectNumber() {
                        arr.append(num)
                    }

                    if arr.count != 3 {
                        throw .parseError(line)
                    }

                    domainMin = arr
                case .lut1DSize:
                    if let num = scanner.expectNumber() {
                        dim = .one(Int(num))
                    } else {
                        throw .parseError(line)
                    }
                case .lut3DSize:
                    if let num = scanner.expectNumber() {
                        dim = .three(Int(num))
                    } else {
                        throw .parseError(line)
                    }
                }
            case .number(let num):
                var nums = [num]
                while let num = scanner.expectNumber() {
                    nums.append(num)
                }

                if nums.count != 3 {
                    throw .parseError(line)
                }

                table.append(contentsOf: nums)
            case .text:
                throw .parseError(line)
            }
        }

        guard let dim = dim else {
            throw .missingLutSize
        }

        switch dim {
            case .one(let size):
                if table.count != 3 * size {
                    throw .invalidTableSize(table.count, shouldBe: 3 * size)
                }
            case .three(let size):
                if table.count != 3 * size * size * size {
                    throw .invalidTableSize(table.count, shouldBe: 3 * size * size * size)
                }
        }

        self.data = table
        self.info = .init(title: title, domainMin: domainMin, domainMax: domainMax, dim: dim)
    }
}

public enum CubeLutError: Error {
    case tokenizer(TokenizerError)
    case repeatedTitle
    case missingLutSize
    case repeatedLutSize
    case parseError(String)
    case invalidTableSize(Int, shouldBe: Int)
}
