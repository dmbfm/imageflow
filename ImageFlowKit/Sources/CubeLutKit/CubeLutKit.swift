import Foundation

public struct CubeLutInfo: Sendable, Equatable {
    public let title: String?
    public let domainMin: [Float32]
    public let domainMax: [Float32]
    public let dim: LutDim
    public let format: CubeLutFormat

    public init(
        title: String? = nil,
        domainMin: [Float32],
        domainMax: [Float32],
        dim: LutDim,
        format: CubeLutFormat = .rgb
    ) {
        self.title = title
        self.domainMin = domainMin
        self.domainMax = domainMax
        self.format = format
        self.dim = dim
    }
}

public enum CubeLutFormat: Sendable, Equatable {
    case rgb
    case rgba
}

public struct CubeLut: Sendable, Equatable {
    public let info: CubeLutInfo
    public let data: Data

    public init(info: CubeLutInfo, data: Data) {
        self.info = info
        self.data = data
    }

    public init(lutArray: CubeLutArray) {
        self.info = lutArray.info
        self.data = lutArray.data.withUnsafeBufferPointer { Data(buffer: $0) }
    }

    public static let identityRGBA: Self = .init(lutArray: .identityRGBA)
    public static let identityRGB: Self = .init(lutArray: .identityRGB)
}

public struct CubeLutArray: Sendable, Equatable {
    public let info: CubeLutInfo
    public let data: [Float32]

    public init(info: CubeLutInfo, data: [Float32]) {
        self.info = info
        self.data = data
    }

    public static let identityRGBA: Self =
        .init(
            info: .init(
                domainMin: .init(repeating: 0, count: 3),
                domainMax: .init(repeating: 1, count: 3),
                dim: .three(2),
                format: .rgba
            ),
            data: [
                0, 0, 0, 1,
                1, 0, 0, 1,
                0, 1, 0, 1,
                1, 1, 0, 1,
                0, 0, 1, 1,
                1, 0, 1, 1,
                0, 1, 1, 1,
                1, 1, 1, 1,
            ]
        )

    public static let identityRGB: Self =
        .init(
            info: .init(
                domainMin: .init(repeating: 0, count: 3),
                domainMax: .init(repeating: 1, count: 3),
                dim: .three(2),
                format: .rgb
            ),
            data: [
                0, 0, 0,
                1, 0, 0,
                0, 1, 0,
                1, 1, 0,
                0, 0, 1,
                1, 0, 1,
                0, 1, 1,
                1, 1, 1,
            ]
        )
}

public enum LutDim: Sendable, Equatable {
    case one(Int)
    case three(Int)
}

extension CubeLut {
    public init(source: String, format: CubeLutFormat = .rgb) throws(CubeLutError) {
        let arr = try CubeLutArray(source: source, format: format)
        self.info = arr.info
        self.data = arr.data.withUnsafeBufferPointer { Data(buffer: $0) }
    }
}

extension CubeLutArray {
    public init(source: String, format: CubeLutFormat = .rgb) throws(CubeLutError) {

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

                if format == .rgba {
                    table.append(1.0)
                }

            case .text:
                throw .parseError(line)
            }
        }

        guard let dim = dim else {
            throw .missingLutSize
        }

        let numComponents =
            switch format {
            case .rgb: 3
            case .rgba: 4
            }

        switch dim {
        case .one(let size):
            if table.count != numComponents * size {
                throw .invalidTableSize(table.count, shouldBe: numComponents * size)
            }
        case .three(let size):
            if table.count != numComponents * size * size * size {
                throw .invalidTableSize(table.count, shouldBe: numComponents * size * size * size)
            }
        }

        self.data = table
        self.info = .init(title: title, domainMin: domainMin, domainMax: domainMax, dim: dim, format: format)
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
