#if os(macOS)

import AppKit

class NodeSearchPopoverListView: NSTableView {

    var onClick: (() -> ())?

    func updateSelection(mouseWindowLocation location: CGPoint) {
        let point = self.convert(location, from: nil)
        if self.bounds.contains(point) {
            let row = self.row(at: point)
            self.selectRowIndexes([row], byExtendingSelection: false)
        }
    }

    func selectNext() {
        let current = self.selectedRow
        let max = self.numberOfRows
        var next = (current + 1)
        if next >= max {
            next = 0
        }
        self.scrollRowToVisible(next)
        self.selectRowIndexes([next], byExtendingSelection: false)
    }

    func selectPrev() {
        let current = self.selectedRow
        let max = self.numberOfRows
        var next = (current - 1)
        if next < 0 {
            next = max - 1
        }

        self.scrollRowToVisible(next)
        self.selectRowIndexes([next], byExtendingSelection: false)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        for ta in self.trackingAreas {
            self.removeTrackingArea(ta)
        }

        self.addTrackingArea(
            .init(
                rect: self.bounds,
                options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways],
                owner: self,
                userInfo: nil
            )
        )
    }

    override func mouseMoved(with event: NSEvent) {
        self.updateSelection(mouseWindowLocation: event.locationInWindow)
    }

    override func mouseDown(with event: NSEvent) {
        self.onClick?()
    }
}

#endif
