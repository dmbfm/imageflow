//
//  ContentView.swift
//  CardStateViewPreview
//
//  Created by Daniel Fortes on 06/12/25.
//

import SwiftUI
import Controls
import Helpers


struct ContentView: View {
    
    @State var size: Bounded<CGFloat> = .init(100...400, 200)!
    @State var alignment: CardAlignment = .bottomTrailing
    @State var dockLocation: CardDockLocation? = nil
    @State var dockHeights: CardDockHeights = .init(up: .init(50...1000, 300)!, down: .init(50...1000, 300)!)
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                CardStageView(self.$size, self.$alignment, self.$dockLocation, self.$dockHeights, .init(width: 25, height: 25)) {
                    Color.teal
                }
            }
            Rectangle()
                .fill(.gray)
                .frame(height: 1)
            HStack {
                Picker("Alignment", selection: self.$alignment) {
                    ForEach(CardAlignment.allCases, id: \.self) { alignment in
                        Text(alignment.rawValue)
                            .tag(alignment)
                    }
                }
                Picker("Dock", selection: self.$dockLocation) {
                    Text("Not docked")
                        .tag(nil as CardDockLocation?)
                    ForEach(CardDockLocation.allCases, id: \.self) { item in
                        Text(item.rawValue)
                            .tag(item as CardDockLocation?)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
