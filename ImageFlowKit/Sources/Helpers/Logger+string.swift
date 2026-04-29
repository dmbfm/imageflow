import OSLog

public extension Logger {
    func trace(string: String) {
        self.trace("\(string)")
    }

    func info(string: String) {
        self.info("\(string)")
    }

    func debug(string: String) {
        self.debug("\(string)")
    }

    func critical(string: String) {
        self.critical("\(string)")
    }

    func error(string: String) {
        self.error("\(string)")
    }

    func warning(string: String) {
        self.warning("\(string)")
    }

    func fault(string: String) {
        self.fault("\(string)")
    }
}
