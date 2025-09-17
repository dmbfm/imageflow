#if canImport(AppKit)

import CanvasFeature
import CommonUtils
import Logging
import Models
import SwiftUI
import SidebarFeature

struct MainViewMac: View {
    @Binding var flow: Flow
    @State var canvasCenter: Box<CGPoint> = .init(.zero)
    @State var dispatcher: Dispatcher = .init()
    @Environment(\.dismissWindow) var dismissWindow

    func dispatch(_ action: Action) {
        log("\(action)", level: .trace)
    }

    func onAppear() {
        self.dispatcher.listen { self.dispatch($0) }
        self.dismissWindow(id: WindowID.welcome.rawValue)
    }

    var body: some View {
        self.mainView
            .environmentObject(self.dispatcher)
            .onAppear(perform: self.onAppear)
    }

    @ViewBuilder
    var mainView: some View {
        NavigationSplitView {
            SidebarFeatureView()
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
        } detail: {
            self.detailView
        }
    }

    @ViewBuilder
    var detailView: some View {
        ZStack {
            CanvasFeatureView(
                self.$flow.canvas,
                self.$flow.nodeData,
                self.$flow.nodeSelection,
            )
            .onGeometryChange(for: CGPoint.self) { proxy in
                proxy.frame(in: .local).center
            } action: { newValue in
                self.canvasCenter.value = newValue
            }
            // .onChange(of: self.flow.canvas, initial: true) {
            // }
        }
    }
}

#endif
