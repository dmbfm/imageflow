import Foundation

public struct Matrix2x2: Sendable, Hashable, Codable {
    public var values: [Double]

    public init() {
        self.values = Array(repeating: 0.0, count: 4)
    }

    public init(_ values: [Double]) {
        self.values = .init(repeating: 0.0, count: 4)
        for i in 0..<4 {
            if values.indices.contains(i) {
                self.values[i] = values[i]
            } else {
                self.values[i] = 0
            }
        }
    }

    public static var zero: Self {
        .init()
    }

    public static var identity: Self {
        .init([1, 0, 0, 1])
    }

    public subscript(row: Int, column: Int) -> Double {
        get {
            self.values[row * 2 + column]
        }
        set {
            self.values[row * 2 + column] = newValue
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 + $1 }))
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 - $1 }))
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        let dim = 2
        var result = Self.init()
        for i in 0..<dim {
            for j in 0..<dim {
                var s = 0.0
                for k in 0..<dim {
                    s += lhs[i, k] * rhs[k, j]
                }
                result[i, j] = s
            }
        }

        return result
    }
}

public struct Matrix3x3: Sendable, Hashable, Codable {
    public var values: [Double]

    public init() {
        self.values = Array(repeating: 0.0, count: 9)
    }

    public init(_ values: [Double]) {
        self.values = .init(repeating: 0.0, count: 9)
        for i in 0..<9 {
            if values.indices.contains(i) {
                self.values[i] = values[i]
            } else {
                self.values[i] = 0
            }
        }
    }

    public static var zero: Self {
        .init()
    }

    public static var identity: Self {
        .init([1, 0, 0, 0, 1, 0, 0, 0, 1])
    }

    public subscript(row: Int, column: Int) -> Double {
        get {
            self.values[row * 3 + column]
        }
        set {
            self.values[row * 3 + column] = newValue
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 + $1 }))
    }
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 - $1 }))
    }
    public static func * (lhs: Self, rhs: Self) -> Self {
        var result = Self.init()
        for i in 0..<3 {
            for j in 0..<3 {
                var s = 0.0
                for k in 0..<3 {
                    s += lhs[i, k] * rhs[k, j]
                }
                result[i, j] = s
            }
        }

        return result
    }
}

public struct Matrix5x5: Sendable, Hashable, Codable {
    public var values: [Double]

    var dim = 5
    var count = 5 * 5

    public init() {
        self.values = Array(repeating: 0.0, count: count)
    }

    public init(_ values: [Double]) {
        self.values = .init(repeating: 0.0, count: count)
        for i in 0..<count {
            if values.indices.contains(i) {
                self.values[i] = values[i]
            } else {
                self.values[i] = 0
            }
        }
    }

    public static var zero: Self {
        .init()
    }

    public static var identity: Self {
        .init([
            1, 0, 0, 0, 0,
            0, 1, 0, 0, 0,
            0, 0, 1, 0, 0,
            0, 0, 0, 1, 0,
            0, 0, 0, 0, 1,
        ])
    }

    public subscript(row: Int, column: Int) -> Double {
        get {
            self.values[row * dim + column]
        }
        set {
            self.values[row * dim + column] = newValue
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 + $1 }))
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 - $1 }))
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        let dim = 5
        var result = Self.init()
        for i in 0..<dim {
            for j in 0..<dim {
                var s = 0.0
                for k in 0..<dim {
                    s += lhs[i, k] * rhs[k, j]
                }
                result[i, j] = s
            }
        }

        return result
    }
}

public struct Matrix7x7: Sendable, Hashable, Codable {
    public var values: [Double]

    var dim = 7
    var count = 7 * 7

    public init() {
        self.values = Array(repeating: 0.0, count: count)
    }

    public init(_ values: [Double]) {
        self.values = .init(repeating: 0.0, count: count)
        for i in 0..<count {
            if values.indices.contains(i) {
                self.values[i] = values[i]
            } else {
                self.values[i] = 0
            }
        }
    }

    public static var zero: Self {
        .init()
    }

    public static var identity: Self {
        .init([
            1, 0, 0, 0, 0, 0, 0,
            0, 1, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 0, 0, 0,
            0, 0, 0, 1, 0, 0, 0,
            0, 0, 0, 0, 1, 0, 0,
            0, 0, 0, 0, 0, 1, 0,
            0, 0, 0, 0, 0, 0, 1,
        ])
    }

    public subscript(row: Int, column: Int) -> Double {
        get {
            self.values[row * dim + column]
        }
        set {
            self.values[row * dim + column] = newValue
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 + $1 }))
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(zip(lhs.values, rhs.values).map({ $0 - $1 }))
    }
    public static func * (lhs: Self, rhs: Self) -> Self {
        let dim = 7
        var result = Self.init()
        for i in 0..<dim {
            for j in 0..<dim {
                var s = 0.0
                for k in 0..<dim {
                    s += lhs[i, k] * rhs[k, j]
                }
                result[i, j] = s
            }
        }

        return result
    }
}
