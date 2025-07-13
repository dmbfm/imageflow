extension String {
    /// Returns a string truncated to `maxLength` characters,
    /// adding "..." if truncation was necessary.
    ///
    /// - Parameter maxLength: The total maximum length of the returned string,
    ///   including the three dots when truncation occurs.
    /// - Returns: Either `self` (if `count ≤ maxLength`), or
    ///   the first `maxLength - 3` characters plus "…".
    public func ellipsisTruncated(to maxLength: Int) -> String {
        // If maxLength is too small to even show "...", just prefix
        guard maxLength > 3 else {
            return String(prefix(maxLength))
        }
        // If no need to truncate, return self
        guard count > maxLength else {
            return self
        }
        let end = index(startIndex, offsetBy: maxLength - 3)
        return self[..<end] + "..."
    }
}
