// import CoreImage
// import Foundation
// import Testing

// @testable import ImageFlowKit

// struct Entry {
//     var input: PreviewContentViewModel.Input
//     var effect: PreviewContentViewModel.Effect?
//     var state: PreviewContentViewModel.State
//     var available: Set<OutputPortLocation>? = nil

//     init(
//         input: PreviewContentViewModel.Input,
//         effect: PreviewContentViewModel.Effect?,
//         state: PreviewContentViewModel.State,
//         available: Set<OutputPortLocation>? = nil
//     ) {
//         self.input = input
//         self.effect = effect
//         self.state = state
//         self.available = available
//     }
// }

// func run(_ p: PreviewContentViewModel, _ sequence: [Entry]) {
//     var p = p
//     for s in sequence {
//         #expect(p.input(s.input) == s.effect)
//         #expect(p.state == s.state)
//         if let available = s.available {
//             #expect(p.available == available)
//         }
//     }
// }

// @Test("PreviewContentViewModel: starting from 'nothing' select and load image")
// func testSelectWhenNothing() {
//     let p = PreviewContentViewModel()!
//     let loc: OutputPortLocation = .init(node: .init(), index: 0)
//     let image: CIImage = .init()
//     run(
//         p,
//         [
//             .init(
//                 input: .sel([loc]),
//                 effect: .startLoading(loc),
//                 state: .loading(false, loc, nil)
//             ),
//             .init(
//                 input: .imageLoaded(loc, image),
//                 effect: nil,
//                 state: .loaded(false, loc, image)
//             ),
//         ]
//     )
// }

// @Test("PreviewContentViewModel: starting from unlocked loaded, deselecting should yield state 'nothing'")
// func testDeselectWhenUnlocked() {
//     let loc: OutputPortLocation = .init(node: .init(), index: 0)
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(available: [loc], state: .loaded(false, loc, image))!
//     run(
//         p,
//         [
//             .init(input: .sel([]), effect: nil, state: .nothing)
//         ]
//     )
// }

// @Test("PreviewContentViewModel: starting from locked loaded, deselecting should not change state")
// func testDeselectWhenLocked() {
//     let loc: OutputPortLocation = .init(node: .init(), index: 0)
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(state: .loaded(true, loc, image))!
//     run(
//         p,
//         [
//             .init(input: .sel([]), effect: nil, state: .loaded(true, loc, image), available: [])
//         ]
//     )
// }

// @Test(
//     "PreviewContentViewModel: starting from unlocked loaded, changing selection containing loaded loc should not change state"
// )
// func testLoadedChangeSelIncludingLoc() {
//     let locs: [OutputPortLocation] = (0...10).map { _ in .init(node: .init(), index: 0) }
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(available: [locs[0]], state: .loaded(false, locs[0], image))!
//     run(
//         p,
//         [
//             .init(input: .sel(.init(locs)), effect: nil, state: .loaded(false, locs[0], image), available: .init(locs))
//         ]
//     )
// }

// @Test(
//     "PreviewContentViewModel: starting from unlocked loaded, changing selection not containing loaded loc should load new image"
// )
// func testLoadedChangeSelNotIncludingLoc() {
//     let locs: [OutputPortLocation] = (0...10).map { _ in .init(node: .init(), index: 0) }
//     let sel = Set(locs.dropFirst())
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(available: [locs[0]], state: .loaded(false, locs[0], image))!
//     run(
//         p,
//         [
//             .init(
//                 input: .sel(sel),
//                 effect: .startLoading(sel.first!),
//                 state: .loading(false, sel.first!, image),
//                 available: sel
//             )
//         ]
//     )
// }

// @Test(
//     "PreviewContentViewModel: starting from locked loaded, changing selection not containing loaded loc should not change state"
// )
// func testLoadedLockedChangeSelNotIncludingLoc() {
//     let locs: [OutputPortLocation] = (0...10).map { _ in .init(node: .init(), index: 0) }
//     let sel = Set(locs.dropFirst())
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(state: .loaded(true, locs[0], image))!
//     run(
//         p,
//         [
//             .init(
//                 input: .sel(sel),
//                 effect: nil,
//                 state: .loaded(true, locs[0], image),
//                 available: sel
//             )
//         ]
//     )
// }

// @Test(
//     "PreviewContentViewModel: starting from locked loaded, unlocking with a non-empty sel not containing curr. location should load new image"
// )
// func testUnlockLoaded() {
//     let locs: [OutputPortLocation] = (0...10).map { _ in .init(node: .init(), index: 0) }
//     let sel = Set(locs.dropFirst())
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(available: sel, state: .loaded(true, locs[0], image))!
//     run(
//         p,
//         [
//             .init(
//                 input: .unlock,
//                 effect: .startLoading(sel.first!),
//                 state: .loading(false, sel.first!, image),
//                 available: sel
//             )
//         ]
//     )
// }

// @Test(
//     "PreviewContentViewModel: starting from locked loaded, unlocking with a empty sel should change state to 'nothing'"
// )
// func testUnlockLoadedWithEmptySel() {
//     let locs: [OutputPortLocation] = (0...10).map { _ in .init(node: .init(), index: 0) }
//     let image: CIImage = .init()
//     let p = PreviewContentViewModel(available: [], state: .loaded(true, locs[0], image))!
//     run(
//         p,
//         [
//             .init(
//                 input: .unlock,
//                 effect: nil,
//                 state: .nothing,
//                 available: []
//             )
//         ]
//     )
// }
