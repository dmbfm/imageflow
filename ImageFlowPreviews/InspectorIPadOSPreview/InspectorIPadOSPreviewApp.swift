//
//  InspectorIPadOSPreviewApp.swift
//  InspectorIPadOSPreview
//
//  Created by Daniel Fortes on 11/03/26.
//

import SwiftUI
import InspectorFeatureIPadOS
internal import SharedModels
internal import Values

@main
struct InspectorIPadOSPreviewApp: App {
    
    
    let nodes: [FlowNode] =
    ValueType.allCases.map({ .init(kind: .valueNode($0)) })
        
    
    var body: some Scene {
        WindowGroup {
            InspectorFeatureView.Preview(nodes: self.nodes)
        }
    }
}
