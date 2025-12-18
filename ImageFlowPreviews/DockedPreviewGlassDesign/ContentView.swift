//
//  ContentView.swift
//  DockedPreviewGlassDesign
//
//  Created by Daniel Fortes on 17/12/25.
//

import SwiftUI
import CIImageView

struct ContentView: View {
    
    @State var image: CIImage?
    @State var zoom: CGFloat = 1.0
    @State var action: CIImageScrollView.Action?
    
    var body: some View {
        NavigationSplitView {} detail:  {
            VStack {
                NavigationStack {
                    ZStack(alignment: .top) {
                        Color.clear
                        
                        CIImageScrollView(
                            image: self.image,
                            zoom: self.$zoom,
                            action: self.$action)
                        .ignoresSafeArea()
                        .toolbar {
                            Button("ok") {}
                        }
                        //
                        //                    HStack {
                        //                        Button("OK") {
                        //
                        //                        }
                        //                        .buttonStyle(.glass)
                        //                    }
                        //                    .frame(maxWidth: .infinity)
                        //                    .frame(height: 50)
                        //                    .ignoresSafeArea()
                    }
                }
            }
            .padding()
        }
        .onAppear {
            let uiImage = UIImage(named: "image")!
            self.image = CIImage(image: uiImage)!
        }
    }
}

#Preview {
    ContentView()
}
