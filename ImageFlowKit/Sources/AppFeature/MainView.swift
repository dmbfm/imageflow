import CanvasFeature
import SwiftUI

#if os(macOS)
typealias MainView = MainViewMac
#else
typealias MainView = MainViewIPad
#endif
//
//struct MainView: View {
//    @Binding var document: ImageFlowDocument
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                Text("\(self.document.canvas.nodePositions.count)")
//            }
//            .searchable(text: .constant(""))
//        } detail: {
//            ZStack {
//                CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
//            }
//        }
//    }
//}
