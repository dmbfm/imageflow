import Controls
import CoreImage
import Helpers
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ImageExportConfiguration

fileprivate struct ImageExportConfiguration: Equatable {

    var representation: Representation = .png
    var quality: Double = 90.0
    var scale: ImageScale = .original
    var depth: ChannelDepth = .depth8
    var size: ImageCustomSize = .init(width: 128, height: 128)

    var contentTypes: [UTType] {
        switch self.representation {
        case .png: [UTType.png]
        case .jpeg: [UTType.jpeg]
        case .heif: [UTType.heic]
        case .tiff: [UTType.tiff]
        }
    }

    // MARK: - ImageCustomSize

    struct ImageCustomSize: Equatable {
        let width: Double
        let height: Double

        init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }

        func withWidth(_ width: Double) -> Self {
            let a = self.width / self.height
            return .init(width: width, height: width / a)
        }

        func withHeight(_ height: Double) -> Self {
            let a = self.width / self.height
            return .init(width: a * height, height: height)
        }
    }

    // MARK: Representation

    enum Representation: String, Equatable, CaseIterable {
        case png = "PNG"
        case jpeg = "JPEG"
        case tiff = "TIFF"
        case heif = "HEIC"

        /// Has compression quality settings: only JPEG and HEIC.
        var hasQualitySettings: Bool {
            switch self {
            case .jpeg, .heif: true
            default: false
            }
        }

        /// Can have 16bit depth: only PNG and TIFF
        var hasChannelDepth: Bool {
            switch self {
            case .png, .tiff: true
            default: false
            }
        }
    }

    // MARK: ChannelDepth

    enum ChannelDepth: Equatable, CaseIterable {
        case depth8
        case depth16

        var label: String {
            switch self {
            case .depth8: "8 Bits"
            case .depth16: "16 Bits"
            }
        }
    }

    // MARK: ImageScale

    enum ImageScale: Equatable, CaseIterable {
        case original
        case half
        case quarter
        case custom

        var label: String {
            switch self {
            case .custom: "Custom"
            case .half: "50%"
            case .original: "Original"
            case .quarter: "25%"
            }
        }
    }
}

// MARK: - View + imageExporter

extension View {
    public func imageExporter(
        isPresented: Binding<Bool>,
        image: CIImage?,
        defaultFilename: String? = nil,
        errorMessage: Binding<LocalizedAlertError?>? = nil
    ) -> some View {
        self.modifier(
            ImageExportModifier(
                isPresented: isPresented,
                image: image,
                defaultFilename: defaultFilename,
                errorMessage: errorMessage
            )
        )
    }
}

// MARK: - ImageExportModifier

public struct ImageExportModifier: ViewModifier {

    let image: CIImage?
    let defaultFilename: String?

    @Binding var isPresented: Bool
    @Binding var errorMessage: LocalizedAlertError?

    @State private var state: _State = .nothing
    @State private var showExportSettings: Bool = false
    @State private var showFileExporter: Bool = false

    private enum _State {
        case nothing
        case settings(CIImage, ImageExportConfiguration, Settings)
        case fileDialog

        enum Settings {
            case loading(Task<(), Never>)
            case loaded(ImageTransferable, ImageExportSettingsView.Info)
        }

        var task: Task<(), Never>? {
            switch self {
            case .settings(_, _, .loading(let task)): task
            default: nil
            }
        }
    }

    private enum _Input {
        case present(CIImage)
        case configurationChanged(ImageExportConfiguration)
        case settingsCancel
        case settingsExport
        case fileExported
        case fileExportCancel
        case fileExportFailed
    }

    struct FileExportError: LocalizedError {
        var err: any Error

        public var errorDescription: String? {
            self.err.localizedDescription
        }
    }

    init(
        isPresented: Binding<Bool>,
        image: CIImage?,
        defaultFilename: String? = nil,
        errorMessage: Binding<LocalizedAlertError?>? = nil
    ) {
        self._isPresented = isPresented
        self._errorMessage = errorMessage ?? .constant(nil)
        self.image = image
        self.defaultFilename = defaultFilename
    }

    private func input(_ input: _Input) {

        func createTask(_ image: CIImage, _ configuration: ImageExportConfiguration) -> Task<(), Never> {
            Task {
                let (t, i) = await encodeImage(image, configuration)
                if !Task.isCancelled {
                    self.state = .settings(image, configuration, .loaded(t, i))
                }
            }
        }

        switch input {
        case .present(let image):
            switch self.state {
            case .nothing:
                var configuration = ImageExportConfiguration()
                configuration.size = .init(width: image.extent.width, height: image.extent.height)
                self.state = .settings(
                    image,
                    .init(),
                    .loading(createTask(image, configuration))
                )
                self.showFileExporter = false
                self.showExportSettings = true
            default:
                break
            }

        case .settingsCancel:
            switch self.state {
            case .nothing: break
            case .fileDialog: break
            case .settings(_, _, _):
                self.state.task?.cancel()
                self.showExportSettings = false
                self.showFileExporter = false
                self.isPresented = false
                self.state = .nothing
            }

        case .settingsExport:
            switch self.state {
            case .nothing: break
            case .fileDialog: break
            case .settings(_, _, .loading(_)):
                break
            case .settings(_, _, .loaded(_, _)):
                self.showExportSettings = false
                self.showFileExporter = true
            }

        case .configurationChanged(let newConfig):
            switch self.state {
            case .settings(let image, _, _):
                self.state.task?.cancel()
                self.state = .settings(
                    image,
                    newConfig,
                    .loading(createTask(image, newConfig))
                )
            default:
                break
            }

        case .fileExported:
            self.state = .nothing
            self.showFileExporter = false
            self.showExportSettings = false
            self.isPresented = false

        case .fileExportCancel, .fileExportFailed:
            self.state = .nothing
            self.showFileExporter = false
            self.showExportSettings = false
            self.isPresented = false
        }

    }

    func fileExporterOnCompletion(_ result: Result<URL, any Error>) {
        switch result {
        case .success(_):
            self.input(.fileExported)
        case .failure(let err):
            self.errorMessage = .init(inner: FileExportError(err: err))
            self.input(.fileExportFailed)
        }
    }

    private var configuration: ImageExportConfiguration? {
        switch self.state {
        case .settings(_, let config, _): config
        default: nil
        }
    }

    private var configurationBinding: Binding<ImageExportConfiguration> {
        .init(
            get: {
                self.configuration ?? .init()
            },
            set: {
                self.input(.configurationChanged($0))
            }
        )
    }

    private var info: ImageExportSettingsView.Info? {
        switch self.state {
        case .settings(_, _, .loaded(_, let info)): info
        default: nil
        }
    }

    private var transferable: ImageTransferable? {
        switch self.state {
        case .settings(_, _, .loaded(let t, _)): t
        default: nil
        }
    }

    private var exportDisabled: Bool {
        switch self.state {
        case .settings(_, _, .loaded(_, _)): false
        default: true
        }

    }

    public func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: self.$showExportSettings,
                content: {
                    ImageExportSettingsView(
                        info: self.info,
                        exportDisabled: self.exportDisabled,
                        configuration: self.configurationBinding,
                    ) {
                        self.input(.settingsExport)
                    } onCancel: {
                        self.input(.settingsCancel)
                    }
                }
            )
            .fileExporter(
                isPresented: self.$showFileExporter,
                item: self.transferable,
                contentTypes: self.configuration?.contentTypes ?? [],
                defaultFilename: self.defaultFilename,
                onCompletion: self.fileExporterOnCompletion(_:),
                onCancellation: {
                    self.input(.fileExportCancel)
                }
            )
            .onChange(
                of: self.isPresented,
                initial: true,
                {
                    if self.isPresented, let image = self.image {
                        self.input(.present(image))
                    }
                }
            )
            .onChange(of: self.showExportSettings) {
                if !self.showExportSettings && !self.showFileExporter {
                    self.input(.settingsCancel)
                }
            }
    }
}

// MARK: - ImageExportSettingsView

private struct ImageExportSettingsView: View {

    var info: Info? = nil
    var exportDisabled: Bool = false

    @Binding var configuration: ImageExportConfiguration

    @State private var showExportDisabled: Bool = false
    @State private var effectiveInfo: Info? = nil
    @State private var exportDisabledTask: Task<(), any Error>? = nil
    @State private var infoTask: Task<(), any Error>? = nil

    private let byteCountFormatter = ByteCountFormatter()

    struct Info: Equatable {
        var fileSize: Int? = nil
        var pixelSize: CGSize? = nil
    }

    var onConfirm: () -> ()

    var onCancel: () -> ()

    var widthBinding: Binding<Int> {
        .init(
            get: {
                Int(round(self.configuration.size.width))
            },
            set: {
                self.configuration.size = self.configuration.size.withWidth(
                    Double($0)
                )
            }
        )
    }

    var heightBinding: Binding<Int> {
        .init(
            get: {
                Int(round(self.configuration.size.height))
            },
            set: {
                self.configuration.size = self.configuration.size.withHeight(
                    Double($0)
                )
            }
        )
    }

    func onChangeOfExportDisabled() {
        if self.exportDisabled {
            self.exportDisabledTask = Task {
                try await Task.sleep(for: .milliseconds(400))
                self.showExportDisabled = true
            }
        } else {
            self.exportDisabledTask?.cancel()
            self.showExportDisabled = false
        }
    }

    func onChangeOfInfo() {
        if let info = self.info {
            self.infoTask?.cancel()
            self.effectiveInfo = info
        } else {
            self.infoTask = Task {
                try await Task.sleep(for: .milliseconds(400))
                self.effectiveInfo = nil
            }
        }
    }

    var _body: some View {
        #if os(macOS)
        self.bodyMacOS
        #else
        self.bodyIOS
        #endif

    }

    var body: some View {
        self._body
            .onChange(
                of: self.exportDisabled,
                initial: true,
                self.onChangeOfExportDisabled
            )
            .onChange(
                of: self.info,
                initial: true,
                self.onChangeOfInfo
            )
    }

    #if os(iOS)
    @ViewBuilder
    var bodyIOS: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                Form {
                    LabeledContent {
                        Picker("", selection: self.$configuration.representation) {
                            ForEach(ImageExportConfiguration.Representation.allCases, id: \.self) { f in
                                Text(f.rawValue)
                            }
                        }
                    } label: {
                        Text("Format")
                    }

                    if self.configuration.representation.hasQualitySettings {
                        LabeledContent {
                            QualitySliderView(value: self.$configuration.quality)
                        } label: {
                            Text("Quality")
                        }
                    }

                    if self.configuration.representation.hasChannelDepth {
                        LabeledContent {
                            Picker("", selection: self.$configuration.depth) {
                                ForEach(ImageExportConfiguration.ChannelDepth.allCases, id: \.self) { item in
                                    Text(item.label)
                                }
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                        } label: {
                            Text("Depth")
                        }
                    }

                    LabeledContent {
                        VStack {
                            Picker("", selection: self.$configuration.scale) {
                                ForEach(ImageExportConfiguration.ImageScale.allCases, id: \.self) { item in
                                    Text(item.label)
                                }
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                        }
                    } label: {
                        VStack {
                            Text("Image Scale")
                        }
                    }

                    if self.configuration.scale == .custom {
                        Section("Image Size") {
                            LabeledContent {
                                HStack {
                                    TextField("", value: self.widthBinding, format: .number.grouping(.never))
                                        .multilineTextAlignment(.trailing)
                                    Text("px")
                                }
                            } label: {
                                Text("Width")
                            }

                            LabeledContent {
                                HStack {
                                    TextField("", value: self.heightBinding, format: .number.grouping(.never))
                                        .multilineTextAlignment(.trailing)
                                    Text("px")
                                }
                            } label: {
                                Text("Height")
                            }
                        }
                    }
                }

                VStack(alignment: .leading) {
                    if let fileSize = self.effectiveInfo?.fileSize {
                        Text("\(byteCountFormatter.string(fromByteCount: Int64(fileSize)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Calculating size...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let pixelSize = self.effectiveInfo?.pixelSize {
                        Text("\(Int(pixelSize.width)) x \(Int(pixelSize.height)) px")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
                .padding(.leading, 20)
                .padding(.bottom, 20)

            }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        self.onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Export...", role: .confirm) {
                        if !self.exportDisabled {
                            self.onConfirm()
                        }
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .navigationTitle("Export Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .presentationDetents([.large])
    }
    #endif

    #if os(macOS)
    var formatField: some View {
        Picker("Format", selection: self.$configuration.representation) {
            ForEach(ImageExportConfiguration.Representation.allCases, id: \.self) { f in
                Text(f.rawValue)
            }
        }
        .controlSize(.small)
    }

    var qualityField: some View {
        LabeledContent {
            QualitySliderView(value: self.$configuration.quality)
        } label: {
            Text("Quality")
        }
    }

    var depthField: some View {
        Picker("Channel Depth", selection: self.$configuration.depth) {
            ForEach(ImageExportConfiguration.ChannelDepth.allCases, id: \.self) { item in
                Text(item.label)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    var scaleCustom: some View {
        HStack(spacing: 4) {
            HStack(spacing: 8) {
                Text("W")
                    .font(.caption)
                IntegerInputView(
                    "",
                    value: self.widthBinding,
                    in: 1...1_000_000
                )
                .textFieldStyle(kind: .roundedBorder)
                .frame(width: 92)

            }
            HStack(spacing: 8) {
                Text("H")
                    .font(.caption)
                IntegerInputView(
                    "",
                    value: self.heightBinding,
                    in: 1...1_000_000
                )
                .textFieldStyle(kind: .roundedBorder)
                .frame(width: 92)
            }

        }
        .controlSize(.small)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 8)
    }

    var scaleField: some View {
        LabeledContent {
            VStack {
                Picker("", selection: self.$configuration.scale) {
                    ForEach(ImageExportConfiguration.ImageScale.allCases, id: \.self) { scale in
                        Text(scale.label)
                    }
                }
                .controlSize(.small)
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity, alignment: .trailing)

                if self.configuration.scale == .custom {
                    self.scaleCustom
                }
            }
        } label: {
            Text("Image Scale")
            if self.configuration.scale == .custom {
                Text("Width and Height in pixels")
            }
        }
    }

    var footerInfoView: some View {
        VStack(alignment: .leading) {
            if let fileSize = self.effectiveInfo?.fileSize {
                Text("\(byteCountFormatter.string(fromByteCount: Int64(fileSize)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Calculating size...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let pixelSize = self.effectiveInfo?.pixelSize {
                Text("\(Int(pixelSize.width)) x \(Int(pixelSize.height)) px")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var footerView: some View {
        VStack(spacing: 0) {

            Divider()

            HStack(alignment: .center) {

                self.footerInfoView

                Spacer()

                Button("Cancel") {
                    self.onCancel()
                }

                Button("Export...") {
                    if !self.exportDisabled {
                        self.onConfirm()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(self.showExportDisabled)
            }
            .padding(.horizontal, 20)
            .frame(height: 64)
        }
    }

    @ViewBuilder
    var bodyMacOS: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Form {
                    self.formatField

                    if self.configuration.representation.hasQualitySettings {
                        self.qualityField
                    }

                    if self.configuration.representation.hasChannelDepth {
                        self.depthField
                    }

                    self.scaleField
                }
                .formStyle(.grouped)

                self.footerView
            }
            .navigationTitle("Export Image")
        }
    }
    #endif  // #if os(macOS)
}

// MARK: - QualitySliderView

private struct QualitySliderView: View {
    @Binding var value: Double

    var body: some View {
        HStack(alignment: .center) {
            Slider(value: self.$value, in: 0...100.0) {
            } ticks: {
                let array: [Double] = stride(from: 0, through: 100, by: 10).map { $0 }
                SliderTickContentForEach(array, id: \.self) { val in
                    SliderTick(val)
                }
            }

            Text(String(format: "%.0f", self.value))
                .frame(width: 30)

            Stepper("", value: self.$value)
                #if os(iOS)
            .frame(width: 100)
                #endif
        }
        .controlSize(.small)
        #if os(iOS)
        .padding(.leading, 50)
        #endif
    }
}

// MARK: - ImageTransferable

private struct ImageTransferable: Transferable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(
            contentType: .png,
            exporting: { $0.data },
            importing: { _ in .init(data: .init()) }
        )
        DataRepresentation(
            contentType: .jpeg,
            exporting: { $0.data },
            importing: { _ in .init(data: .init()) }
        )
        DataRepresentation(
            contentType: .heic,
            exporting: { $0.data },
            importing: { _ in .init(data: .init()) }
        )
        DataRepresentation(
            contentType: .tiff,
            exporting: { $0.data },
            importing: { _ in .init(data: .init()) }
        )
    }
}

// MARK:- encodeImage

@concurrent
private func encodeImage(
    _ image: CIImage,
    _ configuration: ImageExportConfiguration
) async -> (ImageTransferable, ImageExportSettingsView.Info) {
    let context = CIContext()

    let scaledImage =
        switch configuration.scale {
        case .original: image
        case .half: image.transformed(by: .init(scaleX: 0.5, y: 0.5), highQualityDownsample: true)
        case .quarter: image.transformed(by: .init(scaleX: 0.25, y: 0.25), highQualityDownsample: true)
        case .custom:
            {
                let scale = configuration.size.width / image.extent.width
                return image.transformed(by: .init(scaleX: scale, y: scale))
            }()

        }

    let format: CIFormat =
        switch configuration.depth {
        case .depth8: .RGBA8
        case .depth16: .RGBA16
        }

    let colorSpace: CGColorSpace = .init(name: CGColorSpace.sRGB)!

    let options: [CIImageRepresentationOption: Any] = [
        kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 1.0
    ]

    func makeData() -> Data? {
        switch configuration.representation {
        case .png: context.pngRepresentation(of: scaledImage, format: format, colorSpace: colorSpace)
        case .jpeg:
            context.jpegRepresentation(
                of: scaledImage,
                colorSpace: colorSpace,
                options: options
            )
        case .tiff: context.tiffRepresentation(of: scaledImage, format: format, colorSpace: colorSpace)
        case .heif:
            context.heifRepresentation(of: scaledImage, format: format, colorSpace: colorSpace, options: options)
        }
    }

    let data = makeData()!

    #if os(macOS)
    let nsImage = NSImage(data: data)
    let size = nsImage?.size
    #else
    let uiImage = UIImage(data: data)
    let size = uiImage?.size
    #endif

    return (.init(data: data), .init(fileSize: data.count, pixelSize: size))
}

// MARK: - Previews

#Preview("Settings View") {
    @Previewable @State var configuration = ImageExportConfiguration()
    ImageExportSettingsView(configuration: $configuration) {
    } onCancel: {
    }
}

#Preview("imageExporter") {
    @Previewable @State var show: Bool = false
    @Previewable @State var image: CIImage = .blue.cropped(to: .init(x: 0, y: 0, width: 400, height: 300))
    VStack {
        Button("Export") { show = true }
    }
    .frame(width: 600, height: 500)
    .imageExporter(isPresented: $show, image: image)
}
