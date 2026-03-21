extension Double {
    public func snapping(toIncrements inc: Double, epsilon: Double) -> Self {
        let snapped = (self / inc).rounded() * inc
        return if abs(self - snapped) < epsilon {
            snapped
        } else {
            self
        }
    }
}
