import Testing

@testable import ComponentKit

@Test
func testMinMax() {
    {
        let m = MinMax(min: 0, max: 1)
        #expect(m.min == 0)
        #expect(m.max == 1)
    }();

    {
        let m = MinMax(min: 1, max: 0)
        #expect(m.min == 0)
        #expect(m.max == 1)
    }();

    {
        var m = MinMax(min: 0, max: 1)
        m.min = 10
        #expect(m.min == 10)
        #expect(m.max == 10)
    }();

    {
        var m = MinMax(min: 0, max: 1)
        m.min = 0.5
        #expect(m.min == 0.5)
        #expect(m.max == 1)
    }();

    {
        var m = MinMax(min: 1, max: 10)
        m.max = -1
        #expect(m.min == -1)
        #expect(m.max == -1)
    }();

    {
        var m = MinMax(min: 1, max: 10)
        m.max = 2
        #expect(m.min == 1)
        #expect(m.max == 2)
    }();

    {
        let m = MinMax(min: 1, max: 10)
        #expect(m.clamped(to: 0...1) == .init(min: 1, max: 1))
    }();

    {
        let m = MinMax(min: 1, max: 10)
        #expect(m.clamped(to: -10...10) == m)
    }();

    {
        let m = MinMax(min: 1, max: 10)
        #expect(m.clamped(to: 20...50) == .init(min: 20, max: 20))
    }();

    {
        let m = MinMax(min: 0, max: 1)
        #expect(m.moving(.min, byAmount: 0.5) == .init(min: 0.5, max: 1))
        #expect(m.moving(.min, byAmount: 1.5) == .init(min: 1.5, max: 1.5))

        #expect(m.moving(.max, byAmount: 0.5) == .init(min: 0, max: 1.5))
        #expect(m.moving(.max, byAmount: -1.5) == .init(min: -0.5, max: -0.5))
    }();

    {
        let m = MinMax(min: 0.25, max: 0.75)
        let range = 0...1.0

        #expect(m.moving(.min, byFraction: 0.5, ofClampingRange: range) == .init(min: 0.75, max: 0.75))
        #expect(m.moving(.min, byFraction: 0.75, ofClampingRange: range) == .init(min: 1.0, max: 1.0))
        #expect(m.moving(.min, byFraction: 1.0, ofClampingRange: range) == .init(min: 1.0, max: 1.0))
        #expect(m.moving(.min, byFraction: -0.25, ofClampingRange: range) == .init(min: 0.0, max: 0.75))

        #expect(m.moving(.max, byFraction: 0.5, ofClampingRange: range) == .init(min: 0.25, max: 1.0))
        #expect(m.moving(.max, byFraction: -0.5, ofClampingRange: range) == .init(min: 0.25, max: 0.25))
        #expect(m.moving(.max, byFraction: -1.0, ofClampingRange: range) == .init(min: 0, max: 0))
    }();

}
