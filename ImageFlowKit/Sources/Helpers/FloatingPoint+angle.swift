import Foundation

extension FloatingPoint {
	public var degrees: Self {
		self * 180 / .pi
	}

	public var radians: Self {
		self * .pi / 180
	}
}
