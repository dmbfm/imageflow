import Testing

@testable import CubeLutKit

let src = """
    TITLE "ACES Proxy 10 to ACES"

    LUT_1D_SIZE 32

    #comment

    0.0004883 0.0004883 0.0004883
    0.0007714 0.0007714 0.0007714
    0.001219 0.001219 0.001219
    0.001926 0.001926 0.001926
    0.003044 0.003044 0.003044
    0.004809 0.004809 0.004809
    0.007599 0.007599 0.007599
    0.01201 0.01201 0.01201
    0.01897 0.01897 0.01897
    0.02998 0.02998 0.02998
    0.04737 0.04737 0.04737
    0.07484 0.07484 0.07484
    0.1183 0.1183 0.1183
    0.1869 0.1869 0.1869
    0.2952 0.2952 0.2952
    0.4665 0.4665 0.4665
    0.7371 0.7371 0.7371
    1.165 1.165 1.165
    1.84 1.84 1.84
    2.908 2.908 2.908
    4.595 4.595 4.595
    7.26 7.26 7.26
    11.47 11.47 11.47
    18.13 18.13 18.13
    28.64 28.64 28.64
    45.25 45.25 45.25
    71.51 71.51 71.51
    113 113 113
    178.5 178.5 178.5
    282.1 282.1 282.1
    445.7 445.7 445.7
    704.3 704.3 704.3
    """

let src2 = """
    # Created Tue 19 Mar 2013
    LUT_3D_SIZE 2
    0 0 0
    1 0 0
    0 .75 0
    1 .75 0
    0 .25 1
    1 .25 1
    0 1 1
    1 1 1
    """

let src3 = """
    TITLE "Demo"
    LUT_1D_SIZE 3
    DOMAIN_MIN 0 0 0
    DOMAIN_MAX 1 2 3
    0 0 0
    # Comments can go anywhere
    0.5 1 1.5
    1 1 1 
    """

@Test func testParse3() throws {
    let expected = CubeLutArray(
        info: .init(
            title: "Demo",
            domainMin: [0, 0, 0],
            domainMax: [1, 2, 3],
            dim: .one(3)
        ),
        data: [
            0, 0, 0,
            0.5, 1, 1.5,
            1, 1, 1,
        ]
    )

    let lut = try CubeLutArray(source: src3)

    #expect(expected == lut)
}
@Test func testTokenizer3() throws {
    let expectedToks: [[Token]] = [
        [.keyword(.title), .text("Demo")],
        [.keyword(.lut1DSize), .number(3.0)],
        [.keyword(.domainMin), .number(0), .number(0), .number(0)],
        [.keyword(.domainMax), .number(1), .number(2), .number(3)],
        [.number(0), .number(0), .number(0)],
        [.comment],
        [.number(0.5), .number(1), .number(1.5)],
        [.number(1), .number(1), .number(1)],
    ]
    for (idx, line) in src3.components(separatedBy: .newlines).enumerated() {
        let toks = try CubeLutKit.tokenize(line: line)
        #expect(toks == expectedToks[idx])
    }
}

@Test func testParse2() throws {
    let expected = CubeLutArray(
        info: .init(
            title: nil,
            domainMin: [0, 0, 0],
            domainMax: [1, 1, 1],
            dim: .three(2)
        ),
        data: [
            0, 0, 0,
            1, 0, 0,
            0, 0.75, 0,
            1, 0.75, 0,
            0, 0.25, 1,
            1, 0.25, 1,
            0, 1, 1,
            1, 1, 1,
        ]
    )

    let lut = try CubeLutArray(source: src2)

    #expect(expected == lut)
}

@Test func testTokenizer2() async throws {
    let expectedToks: [[Token]] = [
        [.comment],
        [.keyword(.lut3DSize), .number(2.0)],
        [.number(0), .number(0), .number(0)],
        [.number(1), .number(0), .number(0)],
        [.number(0), .number(0.75), .number(0)],
        [.number(1), .number(0.75), .number(0)],
        [.number(0), .number(0.25), .number(1)],
        [.number(1), .number(0.25), .number(1)],
        [.number(0), .number(1), .number(1)],
        [.number(1), .number(1), .number(1)],
    ]
    for (idx, line) in src2.components(separatedBy: .newlines).enumerated() {
        let toks = try CubeLutKit.tokenize(line: line)
        #expect(toks == expectedToks[idx])
    }
}

@Test func testTokenizer1() async throws {
    let expectedToks: [[Token]] = [
        [.keyword(.title), .text("ACES Proxy 10 to ACES")],
        [],
        [.keyword(.lut1DSize), .number(32.0)],
        [],
        [.comment],
        [],
        .init(repeating: .number(0.0004883), count: 3),
        .init(repeating: .number(0.0007714), count: 3),
        .init(repeating: .number(0.001219), count: 3),
        .init(repeating: .number(0.001926), count: 3),
        .init(repeating: .number(0.003044), count: 3),
        .init(repeating: .number(0.004809), count: 3),
        .init(repeating: .number(0.007599), count: 3),
        .init(repeating: .number(0.01201), count: 3),
        .init(repeating: .number(0.01897), count: 3),
        .init(repeating: .number(0.02998), count: 3),
        .init(repeating: .number(0.04737), count: 3),
        .init(repeating: .number(0.07484), count: 3),
        .init(repeating: .number(0.1183), count: 3),
        .init(repeating: .number(0.1869), count: 3),
        .init(repeating: .number(0.2952), count: 3),
        .init(repeating: .number(0.4665), count: 3),
        .init(repeating: .number(0.7371), count: 3),
        .init(repeating: .number(1.165), count: 3),
        .init(repeating: .number(1.84), count: 3),
        .init(repeating: .number(2.908), count: 3),
        .init(repeating: .number(4.595), count: 3),
        .init(repeating: .number(7.26), count: 3),
        .init(repeating: .number(11.47), count: 3),
        .init(repeating: .number(18.13), count: 3),
        .init(repeating: .number(28.64), count: 3),
        .init(repeating: .number(45.25), count: 3),
        .init(repeating: .number(71.51), count: 3),
        .init(repeating: .number(113), count: 3),
        .init(repeating: .number(178.5), count: 3),
        .init(repeating: .number(282.1), count: 3),
        .init(repeating: .number(445.7), count: 3),
        .init(repeating: .number(704.3), count: 3),
        .init(repeating: .number(704.3), count: 3),
    ]

    for (idx, line) in src.components(separatedBy: .newlines).enumerated() {
        let toks = try CubeLutKit.tokenize(line: line)
        #expect(toks == expectedToks[idx])
    }
}

@Test func testParse() throws {
    let expected = CubeLutArray(
        info: .init(
            title: "ACES Proxy 10 to ACES",
            domainMin: [0, 0, 0],
            domainMax: [1, 1, 1],
            dim: .one(32)
        ),
        data: [
            0.0004883, 0.0004883, 0.0004883,
            0.0007714, 0.0007714, 0.0007714,
            0.001219, 0.001219, 0.001219,
            0.001926, 0.001926, 0.001926,
            0.003044, 0.003044, 0.003044,
            0.004809, 0.004809, 0.004809,
            0.007599, 0.007599, 0.007599,
            0.01201, 0.01201, 0.01201,
            0.01897, 0.01897, 0.01897,
            0.02998, 0.02998, 0.02998,
            0.04737, 0.04737, 0.04737,
            0.07484, 0.07484, 0.07484,
            0.1183, 0.1183, 0.1183,
            0.1869, 0.1869, 0.1869,
            0.2952, 0.2952, 0.2952,
            0.4665, 0.4665, 0.4665,
            0.7371, 0.7371, 0.7371,
            1.165, 1.165, 1.165,
            1.84, 1.84, 1.84,
            2.908, 2.908, 2.908,
            4.595, 4.595, 4.595,
            7.26, 7.26, 7.26,
            11.47, 11.47, 11.47,
            18.13, 18.13, 18.13,
            28.64, 28.64, 28.64,
            45.25, 45.25, 45.25,
            71.51, 71.51, 71.51,
            113, 113, 113,
            178.5, 178.5, 178.5,
            282.1, 282.1, 282.1,
            445.7, 445.7, 445.7,
            704.3, 704.3, 704.3,
        ]
    )

    let lut = try CubeLutArray(source: src)

    #expect(expected == lut)
}
