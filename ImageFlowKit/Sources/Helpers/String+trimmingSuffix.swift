extension String {
    public func trimmingSuffix(_ suffix: String) -> String {
        String(self.reversed().trimmingPrefix(suffix.reversed()).reversed())
    }
}
