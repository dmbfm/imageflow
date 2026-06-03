extension Collection {
    public subscript(tryGetAt index: Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
