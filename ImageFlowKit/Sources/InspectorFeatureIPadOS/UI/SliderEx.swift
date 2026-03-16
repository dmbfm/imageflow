//
//  ToggleEx.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 17/03/26.
//

#if os(iOS)

import UIKit
import SwiftUI
import Logging

struct SliderEx: UIViewRepresentable {
    
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    
    @Environment(\.sliderExThumbVisibility) var thumbVisibility
    @Environment(\.sliderExBindingMode) var bindingMode
    @Environment(\.sliderExOnChange) var onChange
    @Environment(\.sliderExFractionalDigits) var digits
    
    enum BindingMode {
        case binding
        case callback
    }
    
    struct Change {
        var value: Double
        var initial: Double?
        var commit: Bool
    }
    
    
    func makeUIView(context: Context) -> UISlider {
        let view = UISlider()
        
        view.sliderStyle = self.thumbVisibility.sliderStyle
        view.isContinuous = true
        view.value = Float(self.value)
        view.minimumValue = Float(self.range.lowerBound)
        view.maximumValue = Float(self.range.upperBound)
        
        view.addTarget(context.coordinator, action: #selector(Coordinator.sliderHandler(slider:event:)), for: .valueChanged)
        view.addTarget(context.coordinator, action: #selector(Coordinator.sliderTouchUp(slider:event:)), for: [.touchUpInside, .touchUpOutside])
        
        context.coordinator.onChange = self.onChange
        context.coordinator.value = self.$value
        context.coordinator.bindingMode = self.bindingMode
        context.coordinator.digits = self.digits
        
        return view
    }
    
    func updateUIView(_ view: UISlider, context: Context) {
        if view.sliderStyle != self.thumbVisibility.sliderStyle {
            view.sliderStyle = self.thumbVisibility.sliderStyle
        }
        
        if view.value != Float(self.value) {
            view.value = Float(self.value)
        }
        
        if view.minimumValue != Float(self.range.lowerBound) {
            view.minimumValue = Float(self.range.lowerBound)
        }
        
         
        if view.maximumValue != Float(self.range.upperBound) {
            view.maximumValue = Float(self.range.upperBound)
        }
        
        context.coordinator.onChange = self.onChange
        context.coordinator.value = self.$value
        context.coordinator.bindingMode = self.bindingMode
        context.coordinator.digits = self.digits
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @MainActor
    class Coordinator {
        
        var onChange: ((SliderEx.Change) -> ())?
        var value: Binding<Double>?
        var bindingMode: SliderEx.BindingMode = .binding
        var ignoreNext: Bool = false
        var digits: Int? = nil
        var initialValue: Double? = nil
        
        @objc
        func sliderTouchUp(slider: UISlider, event: UIEvent) {
            print("touch up: \(slider.value)")
            let newDoubleValue = if let digits = self.digits {
                Double(slider.value).truncateTo(fractionalDigits: digits)
            } else {
                Double(slider.value)
            }
            self.onChange?(.init(value: newDoubleValue, initial: self.initialValue, commit: true))
            self.ignoreNext = true
            self.initialValue = nil
        }
        
        @objc
        func sliderHandler(slider: UISlider, event: UIEvent) {
            if ignoreNext {
                self.ignoreNext = false
                return
            }
                        
            if self.initialValue == nil {
                self.initialValue = self.value?.wrappedValue
            }
            
            let newDoubleValue = if let digits = self.digits {
                Double(slider.value).truncateTo(fractionalDigits: digits)
            } else {
                Double(slider.value)
            }
            
            if let digits = self.digits {
                slider.value = slider.value.truncateTo(fractionalDigits: digits)
            }
            
            print("changed: \(slider.value)")
            
            self.onChange?(.init(value: newDoubleValue, commit: false))

            
            if let value = self.value, self.bindingMode == .binding {
                value.wrappedValue = newDoubleValue
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var sliderExThumbVisibility: Visibility = .visible
    @Entry var sliderExBindingMode: SliderEx.BindingMode = .binding
    @Entry var sliderExOnChange: ((SliderEx.Change) -> ())? = nil
    @Entry var sliderExFractionalDigits: Int? = nil
}

extension View {
    func sliderExThumbVisibility(_ visibility: Visibility) -> some View {
        self.environment(\.sliderExThumbVisibility, visibility)
    }
    
    func sliderExBindingMode(_ mode: SliderEx.BindingMode) -> some View {
        self.environment(\.sliderExBindingMode, mode)
    }
    
    func sliderExOnChange(_ perform: @escaping (SliderEx.Change) -> ()) -> some View {
        self.environment(\.sliderExOnChange, perform)
    }
    
    func sliderExFractionalDigits(_ digits: Int?) -> some View {
        self.environment(\.sliderExFractionalDigits, digits)
    }
    
}

extension Visibility {
    var sliderStyle: UISlider.Style {
        self == .hidden ? .thumbless : .default
    }
}

#Preview {
    @Previewable @State var value: Double = 0.0
    VStack(alignment: .leading) {
        SliderEx(value: $value)
        
        SliderEx(value: $value)
            .sliderExFractionalDigits(2)
            .sliderExBindingMode(.callback)
            .sliderExThumbVisibility(.hidden)
            .tint(.red)
        Text("value: \(value)")
    }
    .sliderExOnChange({ change in
        log("\(change)")
        value = change.value
    })
    .padding()
}

#endif
