import SwiftUI

struct CanvasZoomToolbarControlView: View {

    @Observable
    class ViewModel {
        var zoom: CGFloat = 1.0

        var inc: (() -> ())?
        var dec: (() -> ())?
        var setZoom: ((Double) -> ())?
    }

    let vm: ViewModel

    let zoomValues: [Double] = [
        0.1,
        0.25,
        0.5,
        0.75,
        1,
        1.5,
        2,
        3,
        4,
    ]

    var label: String {
        self.vm.zoom.formatted(FloatingPointFormatStyle<Double>.Percent.percent)
    }

    func label(forZoomValue value: Double) -> String {
        (Double(Int(value * 100)) / 100.0).formatted(FloatingPointFormatStyle<Double>.Percent.percent)
    }

    func isOn(_ value: CGFloat) -> Binding<Bool> {
        .init(
            get: {
                value == self.vm.zoom
            },
            set: { [weak vm = self.vm] newValue in
                if newValue {
                    vm?.setZoom?(value)
                }
            }
        )
    }

    var body: some View {
        HStack(spacing: 0) {
            Button {
                self.vm.inc?()
            } label: {
                Image(systemName: "plus")
            }

            Menu(self.label) {
                ForEach(self.zoomValues, id: \.self) { value in
                    Toggle(self.label(forZoomValue: value), isOn: self.isOn(value))
                }
            }
            .menuIndicator(.hidden)

            Button {
                self.vm.dec?()
            } label: {
                Image(systemName: "minus")
            }
        }
    }
}
