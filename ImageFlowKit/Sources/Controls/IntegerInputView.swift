//
//  IntegerField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 08/01/26.
//

import SwiftUI

public struct IntegerInputView: View {
    
    let title: String
    let range: ClosedRange<Int>
    
    @Binding var value: Int
    @State var text: String = ""
    
    func updateText() {
        self.text = "\(self.value)"
    }
    
    func parseText() {
        if let newValue = Int(self.text) {
            self.value = newValue
        } else {
            self.updateText()
        }
    }
    
    public init(_ title: String, value: Binding<Int>, in range: ClosedRange<Int> = Int.min...(Int.max-1)) {
        self.title = title
        self.range = range
        self._value = value
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            TextField(self.title, text: self.$text)
                .onSubmit { self.parseText() }
            Stepper("", value: self.$value, in: self.range)
        }
        .onChange(of: self.value, initial: true) {
            self.updateText()
        }
    }
}

#Preview {
    @Previewable @State var value: Int = 100
    VStack {
        IntegerInputView("", value: $value, in: 0...1_000_000)
    }
    .padding()
}
