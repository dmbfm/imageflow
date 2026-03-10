#if os(iOS)

import Helpers
import Logging
import SwiftUI
import PhotosUI
import SharedModels
import CanvasFeature
import AssetManager
import PreviewFeature
import NodePaletteFeature
import AssetBrowserFeature

struct MainContentViewIPadOS: View {

    @FocusState var focus: Focus?

    @ObservableState var vm: MainContentViewModel

    @FocusedValue(PreviewFeatureState.self)
    var previewState: PreviewFeatureState?

    @Environment(\.undoManager) var undoManager

    var undoObserver = NotificationCenter.default.publisher(for: .NSUndoManagerCheckpoint)

    init(
        flow: Flow,
        canvas: CanvasFeatureState,
        assetStore: AssetStore,
        coordinator: GlobalCoordinator,
    ) {
        self._vm = .init(
            wrappedValue: .init(
                flow: flow,
                canvas: canvas,
                assetStore: assetStore,
                coordinator: coordinator
            )
        )
    }

    var body: some View {
        self.content
            .sheet(isPresented: self.$vm.nodePaletteState.isPresented) {
                NodePaletteSheetView(port: self.vm.nodePaletteState.typedPortLocation, focus: self.$focus) {
                    self.vm.onNodePaletteSheetTapItem($0)
                }
            }
            .sheet(isPresented: self.$vm.showAssetBrowser) {
                AssetBrowserView(self.vm.assetBrowserViewModel)
                    .errorAlert(self.$vm.assetBrowserError)
            }
            .fileImporter(
                isPresented: self.$vm.showFileImporter,
                allowedContentTypes: self.vm.fileImporterConfiguration.allowedContentTypes,
                allowsMultipleSelection: true,
                onCompletion: self.vm.fileImporterCompletionHandler(_:)
            )
            .photosPicker(
                isPresented: self.$vm.showPhotoPicker,
                selection: self.$vm.selectedPhotoPickerItems,
                matching: .images,
                photoLibrary: .shared(),
            )
            .imageExporter(
                isPresented: self.$vm.imageExporterState.isPresented,
                image: self.vm.imageExporterState.image,
                defaultFilename: self.vm.imageExporterState.defaultFilename,
                errorMessage: self.$vm.error,
            )
            .errorAlert(self.$vm.error)
            .onChange(of: self.undoManager, initial: true) { self.vm.undoManager = self.undoManager }
            .onChange(of: self.focus, initial: true, { self.vm.focusDidChange(self.$focus) })
            .onChange(of: self.vm.showFileImporter, initial: false, self.vm.onChangeOfShowFileImporter)
            .onChange(of: self.vm.showPhotoPicker, initial: false, self.vm.onChangeOfShowPhotoPicker)
            .onChange(of: self.vm.selectedPhotoPickerItems, initial: false, self.vm.onChangeOfPhotoPickerItems)
            .onReceive(self.undoObserver) { _ in self.vm.onUndoCheckpoint() }
            .defaultFocus(self.$focus, .global)
            .activeViewObject(self.vm)
            .toolbar { self.toolbarContent }
    }

    @ViewBuilder
    var content: some View {
        CanvasFeatureView(
                self.vm.canvas,
                self.vm.flow,
                self.vm.assetStore,
                self.$focus,
                coordinator: self.vm.coordinator,
            )
        .safeAreaInset(edge: .trailing) {
            if self.vm.showInspector {
                    VStack {
                        InspectorView(flow: self.vm.flow, coordinator: self.vm.coordinator)
                        Spacer()
                    }
                    .frame(width: 300)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 12)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: self.vm.showInspector)
            
//            .toolbar { self.toolbarContent }
//            .focusable()
//            .focused(self.$focus, equals: .global)
//            .focusEffectDisabled()
//            .inspector(isPresented: self.$vm.showInspector, content: {
//                InspectorView(flow: self.vm.flow, coordinator: self.vm.coordinator)
//                    .toolbar {
//                        ToolbarItem(id: "toggle-inspector-v2") {
//                            Button("Toggle Inspector", systemImage: "sidebar.right") {
//                                self.vm.showInspector.toggle()
//                            }
//                        }
//                    }
//            })
//                    .toolbar { self.toolbarContent }
//            .toolbarRole(.editor)
//        NavigationStack {
//            GeometryReader { proxy in
//                ScrollView([.vertical]) {
//                    self.canvasView
//                        .frame(width: proxy.size.width, height: proxy.size.height)
//                        
//                }
//                .scrollEdgeEffectStyle(.soft, for: .vertical)
//                .scrollDisabled(true)
//            }
//            .ignoresSafeArea()
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { self.toolbarContent }
//            .toolbarRole(.editor)
//            .inspector(isPresented: self.vm.showInspectorSafeBinding) {
//                InspectorView(flow: self.vm.flow, coordinator: self.vm.coordinator)
//                    .inspectorColumnWidth(min: 200, ideal: 350, max: 600)
//            }
//        }
//        .inspector(isPresented: self.$vm.showInspector, content: { InspectorView(flow: self.vm.flow, coordinator: self.vm.coordinator) })
    }

//    @ViewBuilder
//    var canvasView: some View {
//        ZStack {
//            CanvasFeatureView(
//                self.vm.canvas,
//                self.vm.flow,
//                self.vm.assetStore,
//                self.$focus,
//                coordinator: self.vm.coordinator,
//            )
//            .focusable()
//            .focused(self.$focus, equals: .global)
//            .focusEffectDisabled()
//            .inspector(isPresented: self.$vm.showInspector, content: { InspectorView(flow: self.vm.flow, coordinator: self.vm.coordinator) })
//        }
//    }
    
    let zoomValues: [CGFloat] = [
        0.1,
        0.25,
        0.5,
        0.75,
        1,
    ]
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {

        ToolbarItemGroup(placement: .secondaryAction) {
            Button {
                self.vm.coordinator.perform(userAction: .viewport(.zoomIn))
            } label: {
                Image(systemName: "plus")
            }
            .disabled(self.vm.canvas.viewport.scale >= 1.0)

            Menu {
                Button("Fit Content") {
                    self.vm.coordinator.perform(userAction: .viewport(.zoomToFitContent))
                }
                .disabled(self.vm.flow.nodes.isEmpty)
                Button("Fit Selected") {
                    self.vm.coordinator.perform(userAction: .viewport(.zoomToFitSelection))
                }
                .disabled(self.vm.flow.selection.isEmpty)
                Divider()
                ForEach(self.zoomValues, id: \.self) { value in
                    Button(zoomFormatter.string(for: value) ?? "") {
                        self.vm.coordinator.perform(userAction: .viewport(.setZoom(value)))
                    }
                }
            } label: {
                Text(zoomFormatter.string(for: self.vm.canvas.viewport.scale) ?? "")
            }

            Button {
                self.vm.coordinator.perform(userAction: .viewport(.zoomOut))
            } label: {
                Image(systemName: "minus")
            }
            .disabled(self.vm.canvas.viewport.scale <= 0.1)
        }

        ToolbarItem(placement: .primaryAction) {
            Button { [weak vm = self.vm] in
                vm?.nodePalettePresent()
            } label: {
                Image(systemName: "plus")
            }
            .keyboardShortcut(.init(.space, modifiers: []))
        }

        ToolbarItem(placement: .primaryAction) {
            Button {

            } label: {
                Image(systemName: "paperclip")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            if let previewState = self.previewState {
                @Bindable var p = previewState

                Menu("Preview", systemImage: "photo.on.rectangle") {
                    Picker("Preview", selection: $p.previewPosition) {
                        Label("Top Left", systemImage: "inset.filled.topleft.rectangle")
                            .tag(PreviewPosition.topLeft)
                        Label("Top Right", systemImage: "inset.filled.topright.rectangle")
                            .tag(PreviewPosition.topRight)
                        Label("Bottom Left", systemImage: "inset.filled.bottomleft.rectangle")
                            .tag(PreviewPosition.bottomLeft)
                        Label("Bottom Right", systemImage: "inset.filled.bottomright.rectangle")
                            .tag(PreviewPosition.bottomRight)
                        Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                            .tag(PreviewPosition.topDock)
                        Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                            .tag(PreviewPosition.bottomDock)
                    }
                    .labelsVisibility(.visible)
                }
            }
        }

        ToolbarSpacer(.fixed, placement: .primaryAction)

        ToolbarItem(placement: .primaryAction) {
            Menu(self.vm.primaryUndoAction.label, systemImage: self.vm.primaryUndoAction.icon) {
                Button("Undo", systemImage: "arrow.uturn.backward") {
                    self.undoManager?.undo()
                }
                .disabled(!self.vm.canUndo)
                Button("Redo", systemImage: "arrow.uturn.forward") {
                    self.undoManager?.redo()
                }
                .disabled(!self.vm.canRedo)
            } primaryAction: {
                switch self.vm.primaryUndoAction {
                case .disabled:
                    break
                case .undo:
                    self.undoManager?.undo()
                case .redo:
                    self.undoManager?.redo()
                }
            }
            .disabled(self.vm.primaryUndoAction == .disabled)
        }

//        ToolbarSpacer(.fixed, placement: .primaryAction)
        ToolbarSpacer(.flexible)

        ToolbarItem(placement: .primaryAction) {
            Button {
//                self.vm.openAssetBrowser()
                
                                                self.vm.showInspector.toggle()
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
            }
        }
        
//        ToolbarSpacer(.fixed, placement: .primaryAction)
//        
//        ToolbarItem(id: "toggle-inspector-v2", placement: .primaryAction) {
//            Button("Toggle Inspector", systemImage: "sidebar.right") {
//                self.vm.showInspector.toggle()
//            }
//        }
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()
#endif
