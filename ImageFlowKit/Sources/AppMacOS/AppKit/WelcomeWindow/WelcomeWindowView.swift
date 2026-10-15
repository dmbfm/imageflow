#if canImport(AppKit)

import SwiftUI
import AppKit
import SharedModels

public struct WelcomeWindowView: View {

    let recentDocuments: [RecentDocumentItem]
    @State var closeButtonHover: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismissWindow) var dismissWindow

    public init(recentDocuments: [RecentDocumentItem]) {
        self.recentDocuments = recentDocuments
    }

    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "ImageFlow"
    }

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.1"
    }

    var appBuild: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    var appVersionString: String {
        if let build = self.appBuild {
            "Version \(self.appVersion)(\(build))"
        } else {
            "Version \(self.appVersion)"
        }
    }

    @ViewBuilder
    var listBackgroundView: some View {
        switch self.colorScheme {
        case .dark:
            Color(.black).opacity(0.075).background(.thickMaterial)
        default:
            Color(.white).opacity(0.6).background(.thickMaterial)
        }
    }

    @ViewBuilder
    var contentView: some View {
        let darkColor = #colorLiteral(red: 0.137, green: 0.137, blue: 0.137, alpha: 1.0)

        ZStack(alignment: .topLeading) {
            Color(self.colorScheme == .dark ? darkColor : .white)
                .frame(width: 460)

            self.closeButtonView

            self.contentBodyView
        }
    }

    var shadowColor: Color {
        if self.colorScheme == .dark {
            .white.opacity(0.12)
        } else {
            .black.opacity(0.42)
        }
    }

    var imageName: String {
        self.colorScheme == .dark ? "logo-dark" : "logo"
    }

    @ViewBuilder
    var contentBodyView: some View {
        VStack(spacing: 0) {

            Spacer().frame(height: 36)

            Image(self.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 128)
                .frame(maxWidth: 460)
                .shadow(color: self.shadowColor, radius: 20)

            Spacer().frame(height: 10)

            Text(self.appName)
                .bold()
                .font(.system(size: 38))
                .foregroundStyle(.primary)

            Spacer().frame(height: 4)

            Text(self.appVersionString)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Spacer().frame(height: 40)

            self.actionButtonsView

            Spacer()
        }
        .fontDesign(.rounded)
        .frame(width: 460)
    }

    @ViewBuilder
    var actionButtonsView: some View {
        VStack(spacing: 8) {
            ActionButton("Create New Flow...", icon: "document") {
                Task { @MainActor in
                    NSDocumentController.shared.newDocument(nil)
                }
                self.dismissWindow()
            }
            ActionButton("Open Existing Flow...", icon: "folder") {
                Task { @MainActor in
                    NSDocumentController.shared.openDocument(nil)
                }
                self.dismissWindow()
            }
            ActionButton("Contact And Support", icon: "envelope") {
                if let del_ = NSApp.delegate, let del = del_ as? AppDelegate {
                    del.openSupport(nil)
                }
            }
        }
        .padding(.horizontal, 48)
    }

    var closeButtonPadding: EdgeInsets {
        EdgeInsets(top: 20, leading: 19, bottom: 0, trailing: 0)
    }

    var closeButtonView: some View {
        Button {
            self.dismissWindow()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 13))
        }
        .onHover { value in
            withAnimation(.spring(duration: 0.2, bounce: 0, blendDuration: 0)) {
                self.closeButtonHover = value
            }
        }
        .help("Close")
        .accessibilityLabel("Close")
        .foregroundStyle(self.closeButtonHover ? .secondary : .tertiary)
        .buttonStyle(.plain)
        .padding(self.closeButtonPadding)
    }

    public var body: some View {
        HStack(spacing: 0) {

            self.contentView
                .frame(width: 460)

            Group {
                RecentDocumentsListView(items: self.recentDocuments)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background {
                self.listBackgroundView
            }
        }
    }
}

#endif
