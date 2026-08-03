//
//  ContentView.swift
//  ComponentKitPreviews
//
//  Created by Daniel Fortes on 04/08/26.
//

import SwiftUI
import ComponentKit

struct ContentView: View {
    var body: some View {
        VStack {
            FontPickerRepresentable()
        }
        .padding()
    }
}

struct FontPickerRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        FontPicker()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}

#Preview {
    ContentView()
}
