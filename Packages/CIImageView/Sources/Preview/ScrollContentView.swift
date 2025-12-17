//
//  ScrollContentView.swift
//  CIImageView
//
//  Created by Daniel Fortes on 15/12/25.
//

import CIImageView
import CoreImage
import SwiftUI

struct ScrollContentView: View {
    @State var image: CIImage? = nil
    @State var zoom: CGFloat = 1.0
    @State var action: CIImageScrollView.Action?

    var body: some View {
        VStack {

            Color(white: 0.25)
                .frame(height: 300)

            ZStack(alignment: .top) {
                Color(white: 0.45)
                CIImageScrollView(image: self.image, zoom: self.$zoom, action: self.$action)
                if #available(macOS 26, *) {
                    HStack {
                        Button("OK") {}
                            .buttonStyle(.glass)
                            .shadow(radius: 4)
                    }
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.white
                        // Rectangle()
                        //     .fill(.ultraThinMaterial)
                    }
                }
            }
            .onAppear {
                let nsImage = Bundle.module.image(forResource: "image.png")!
                self.image = CIImage(data: nsImage.tiffRepresentation!)!
            }
        }
    }
}

#Preview {
    ScrollContentView()
}
