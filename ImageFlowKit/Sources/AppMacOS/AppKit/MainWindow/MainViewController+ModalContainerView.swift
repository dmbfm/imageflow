import CoreImage
import Helpers
import SharedModels
import SwiftUI

extension MainViewController {

    @Observable
    class ModalContainerViewModel {

        var imageExporterState: ImageExporterState = .init()
        var error: LocalizedAlertError?

        struct ImageExporterState {
            var image: CIImage?
            var isPresented: Bool {
                get {
                    self.image != nil
                }
                set {
                    if !newValue {
                        self.image = nil
                    }
                }
            }
            var defaultFilename: String?
        }

        func showImageExporter(_ image: CIImage, _ defaultFilename: String?) {
            self.imageExporterState = .init(image: image, defaultFilename: defaultFilename)
        }
    }

    struct ModalContainerView: View {

        @Bindable var vm: ModalContainerViewModel

        var body: some View {
            EmptyView()
                .imageExporter(
                    isPresented: self.$vm.imageExporterState.isPresented,
                    image: self.vm.imageExporterState.image,
                    defaultFilename: self.vm.imageExporterState.defaultFilename,
                    errorMessage: self.$vm.error
                )
        }
    }

}
