//
//  DraggableFloatInput.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 21/03/26.
//


import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct DraggableFloatInput: View {
    let value: Double
    var sensitivity: Double = 0.1
    var fractionalDigits: Int? = 2
    var onChange: (Change) -> ()
    
    @State var initialValue: Double = 0.0
    @State var initialDragValue: Double? = nil
    
    @Environment(\.colorScheme) var cs
    @Environment(\.draggableFloatInputLeadingSpacing) var spacing
    @Environment(\.draggableFloatInputSnapping) var snapping
    @Environment(\.isEnabled) var enabled
    
    struct Snapping {
        var increment: Double
        var tolerance: Double
    }
    
    init(value: Double, sensitivity: Double = 0.1, fractionalDigits: Int? = 2, onChange: @escaping (Change) -> Void) {
        self.value = value
        self.sensitivity = sensitivity
        self.onChange = onChange
        self.fractionalDigits = fractionalDigits
    }
    
    struct Change {
        var value: Double
        var previous: Double?
        var commit: Bool
    }
    
    func truncatingToFractionalDigits(_ value: Double) -> Double {
        if let fractionalDigits = self.fractionalDigits {
            value.truncateTo(fractionalDigits: fractionalDigits)
        } else {
            value
        }
    }
    
    func newDraggedValue(initial: Double, translation: Double) -> Double {
        self.snapping
            .maybeReduce(
                self.truncatingToFractionalDigits(initial + self.sensitivity * translation)) { acc, curr in
                    acc.snapping(toIncrements: curr.increment, epsilon: curr.tolerance)
                }
    }
    
    func onDragChanged(_ translation: CGSize) {
        if self.initialDragValue == nil {
            self.initialDragValue = self.value
        }
        
        if let initial = self.initialDragValue {
            let newValue = newDraggedValue(initial: initial, translation: translation.width)
            self.onChange(.init(value: newValue, previous: initial, commit: false))
        }
    }
    
    func onDragEnded(_ translation: CGSize) {
        if let initial = self.initialDragValue {
            let newValue = newDraggedValue(initial: initial, translation: translation.width)
            self.onChange(.init(value: newValue, previous: initial, commit: true))
        }
        self.initialDragValue = nil
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: spacing)
            TextFieldEx(
                text: .init(
                    get: {
                        formatter.string(for: self.value) ?? ""
                    },
                    set: { newValue in
                    }
                )
            )
            .textFieldExStyle(.inspectorDefault)
            .textFieldExForegroundColor(self.enabled ? nil : .secondaryLabel)
            .textFieldExDidBeginEditing { text in
                self.initialValue = self.value
            }
            .textFieldExDidChange { text in
            }
            .textFieldExDidEndEditing { text in
                if let number = Double(text) {
                    self.onChange(.init(value: number, previous: self.initialValue, commit: true))
                }
            }
            .textFieldExDragGestureHandler(
                .init(onChange: { self.onDragChanged($0) }, onEnded: { self.onDragEnded($0) })
            )
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .gesture(
            DragGesture()
                .onChanged({ value in self.onDragChanged(value.translation) })
                .onEnded({ value in self.onDragEnded(value.translation) })
        )
    }
}
