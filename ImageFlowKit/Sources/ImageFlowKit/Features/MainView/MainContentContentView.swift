import SwiftUI

struct MainViewContentView: View {

    let flow: Flow
    let canvas: CanvasFeatureState
    @FocusState var focus: Focus?

    var body: some View {
        NavigationSplitView {
            SidebarFeatureView(self.$focus)
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
        } detail: {
            DetailView(flow: self.flow, canvas: self.canvas, focus: self.$focus)
        }
    }
}

fileprivate struct DetailView: View {

    let flow: Flow
    let canvas: CanvasFeatureState
    let focus: FocusState<Focus?>.Binding

    var body: some View {
        ZStack {
            CanvasFeatureView(self.canvas, self.flow, self.focus)
        }
    }
}
