//
//  ContentView.swift
//  ImageExporterPreview
//
//  Created by Daniel Fortes on 08/01/26.
//

import ImageFlowKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {

  @State var image: CIImage? = .blue.cropped(to: .init(x: 0, y: 0, width: 400, height: 300))
  @State var showFileImporter: Bool = false
  @State var showImageExporter: Bool = false
  @State var errorMessage: LocalizedAlertError? = nil
  @State var showErrorMessage: Bool = false

  static let image: CIImage = {
    .blue.cropped(to: .init(x: 0, y: 0, width: 400, height: 300))
  }()

  var body: some View {
    VStack {

      Button("Load Image...") {
        self.showFileImporter = true
      }

      Button("Export Image...") {
        self.showImageExporter = true
      }
    }
    .frame(minWidth: 500, minHeight: 500)
    .imageExporter(
      isPresented: self.$showImageExporter, image: self.image, errorMessage: self.$errorMessage
    )
    .fileImporter(
      isPresented: self.$showFileImporter, allowedContentTypes: [.image],
      allowsMultipleSelection: false
    ) { result in
      guard case .success(let urls) = result, let url = urls.first else {
        print("failed!")
        return
      }

      _ = url.startAccessingSecurityScopedResource()
      defer { url.stopAccessingSecurityScopedResource() }

      self.image = CIImage(contentsOf: url)

      print("loaded!")
    }
    .errorAlert(self.$errorMessage)
  }
}

#Preview {
  ContentView()
}
