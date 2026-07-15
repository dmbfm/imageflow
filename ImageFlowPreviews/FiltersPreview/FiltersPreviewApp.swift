//
//  FiltersPreviewApp.swift
//  FiltersPreview
//
//  Created by Daniel Fortes on 26/07/26.
//

import SwiftUI
import Filters
import XKit
import Helpers
internal import Values

@main
struct FiltersPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            PreviewRepresentable()
        }
    }
}

struct PreviewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        PreviewView()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}

import AppKit
class PreviewView: NSView {
    
    lazy var image: NSImage = {
        let context = CIContext()
        let filter = GradientFilter()
//        filter.gradientData.interpolation = .step
//        filter.gradientData.noiseAmount = 1.0
        let ciImage = filter.outputImage!.cropped(to: .init(x: 0, y: 0, width: 256, height: 256))
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        return NSImage(cgImage: cgImage, size: .init(width: cgImage.width, height: cgImage.height))
    }()
    
    lazy var imageView: NSImageView = {
        .init(image: self.image)
    }()
    
    init() {
        super.init(frame: .zero)
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    PreviewView()
}
