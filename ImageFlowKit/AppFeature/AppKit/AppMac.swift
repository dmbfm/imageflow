//
//  AppMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

#if canImport(AppKit)

import AppKit
import SwiftUI
import Logging
import CommonUtils

@MainActor
public struct ImageFlowApp {
    public static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var welcomeWC: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("", level: .trace)
        NSApp.setupMainMenu()
        // NSDocumentController.shared.openDocument(nil)
        self.showWelcomeWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        log("", level: .trace)
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ app: NSApplication, hasVisibleWindows: Bool) -> Bool {
        log("xxx !!!!!!!!!!!!!!!")
        if hasVisibleWindows {
            return true
        }

        self.showWelcomeWindow()
        return false
    }

    func showWelcomeWindow() {
        if self.welcomeWC == nil {
            let window = NSWindow(
                contentRect: .init(x: 0, y: 0, width: 740, height: 460),
                styleMask: [],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.isOpaque = false
            window.hasShadow = true
            window.backgroundColor = .clear
            window.contentView = NSHostingView(
                rootView: WelcomeWindowView() { [weak self] in self?.welcomeWC?.close() }
            )
            window.isMovableByWindowBackground = true
            self.welcomeWC = NSWindowController(window: window)
        }

        self.welcomeWC?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        if let ss = self.welcomeWC?.window?.screen?.visibleFrame.size, let window = self.welcomeWC?.window {
            window.setFrameOrigin(
                .init(x: ss.width * 0.5 - window.frame.width * 0.5, y: ss.height * 0.5 - window.frame.height * 0.5)
            )
        }
    }
}

struct ActionButton: View {
    let text: String
    let icon: String
    let action: () -> ()
    var body: some View {
        Button {
            self.action()
        } label: {
            HStack {
                Image(systemName: self.icon)
                    .font(.system(size: 20))
                    .padding(.leading, 8)
                    .foregroundStyle(.secondary)
                Text(self.text)
                    .bold()
                    .fontDesign(.rounded)
                Spacer()
            }
            .frame(height: 40)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct WelcomeWindowView: View {

    let close: () -> ()
    @State var closeButtonHover: Bool = false

    var body: some View {
        HStack {
            ZStack {
                Color.clear
                VStack(spacing: 0) {
                    Image("placeholder-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 160)
                        .padding(.top, 20)
//                        .border(.red)
                    Text("Image Flow")
                        .bold()
                        .font(.system(size: 38))
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .padding(.top, 10)
                    Text("Version 0.0.1")
                        .padding(.top, 8)
                        .font(.system(size: 12))
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                    
                    VStack {
                        ActionButton(text: "Create New Flow...", icon: "document", action: {})
                        ActionButton(text: "Open Existing Flow...", icon: "folder", action: {})
                        ActionButton(text: "Contact And Support", icon: "envelope", action: {})
                    }
                    .padding(.top, 40)
                    .frame(width: 360)
                    
                    Spacer()
                }
                
                ZStack(alignment: .topLeading) {
                    Color.clear
                    Button {
                        self.close()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                    }
                    .onHover { value in
                        withAnimation(.spring(duration: 0.2, bounce: 0, blendDuration: 0)) {
                            self.closeButtonHover = value
                        }
                    }
                    .foregroundStyle(self.closeButtonHover ? .secondary : .tertiary)
                    .buttonStyle(.plain)
                    .padding(.leading, 12)
                    .padding(.top, 12)
                }
            }
            .frame(width: 460)
            .background(
                Color(nsColor: .init(light: .white, dark: NSColor(red: 0.137, green: 0.137, blue: 0.137, alpha: 1.0)))
            )
            Spacer()
        }
        .frame(width: 740, height: 460)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    WelcomeWindowView() {}
}

#endif
