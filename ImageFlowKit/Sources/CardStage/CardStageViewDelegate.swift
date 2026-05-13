import Foundation

public protocol CardStageViewDelegate: AnyObject {
    func cardStageAnchorDidChange(_ sender: CardStageView)
    func cardStageDockLocationDidChange(_ sender: CardStageView)

    func cardStageDidStartDocking(_ sender: CardStageView)
    func cardStageDidFinnishDocking(_ sender: CardStageView)

    func cardStageDidStartUndocking(_ sender: CardStageView)
    func cardStageDidFinnishUndocking(_ sender: CardStageView)

    func cardStageDidStartResizingCard(_ sender: CardStageView, locationInWindow: CGPoint)
    func cardStageDidFinnishResizingCard(_ sender: CardStageView, locationInWindow: CGPoint)
}
