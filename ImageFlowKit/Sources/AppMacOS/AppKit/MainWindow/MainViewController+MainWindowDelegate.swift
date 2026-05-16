extension MainViewController: MainWindowDelegate {
    func mainWindowEvent(_ event: MainWindow.Event) {
        switch event {
        case .escapeDown:
            if !self.flow.selection.isEmpty {
                self.flow.selectNone()
            }
        case .spacebarDown(let locationInWindow):
            Task {
                self.perform(
                    userAction: .showNodeSearch(
                        typedPortLocation: nil,
                        canvasPosition: locationInWindow.map({
                            self.canvasView.convert($0, from: nil).clamped(toRect: self.canvasView.safeAreaRect)
                        })
                    )
                )
            }
        }
    }

    func mainWindowShouldAcceptEscapeKeyDown() -> Bool {
        !self.flow.selection.isEmpty
    }
}
