import Controls
import SwiftUI

typealias PreviewToolbarElementID = Sendable & Hashable

enum PreviewToolbarElement<ID: PreviewToolbarElementID> {
    case spacer
    case item(Item)
    case pair(id: String, Item, Item)
    case trio(id: String, Item, Item, Item)
    case quartet(id: String, Item, Item, Item, Item)

    case zoomGroup(id: String, Item, Item, String, Item, Item)

    struct Item: Equatable {
        var id: ID
        var icon: String
        var disabled: Bool = false

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
    }
}

struct PreviewToolbarView<ID: PreviewToolbarElementID>: View {

    let elements: [PreviewToolbarElement<ID>]
    var visible: Bool = true
    var alignment: Alignment = .topLeading
    var handler: (ID) -> ()
    private let buttonSize: CGFloat = .when(macos: 28.0, ios: 36.0)
    private let pairSpacing: CGFloat? = .when(macos: 0.0, ios: nil)

    @Namespace var ns

    var body: some View {
        let els = elements.enumerated()
        ZStack(alignment: self.alignment) {
            Color.clear
            HStack {
                ForEach(els, id: \.offset) { _, el in
                    self.viewForElement(el)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
            .circleGlassButtonSize(self.buttonSize)
        }
    }

    @ViewBuilder
    func viewForElement(_ el: PreviewToolbarElement<ID>) -> some View {
        switch el {
        case .spacer: Spacer()
        case .item(let item):
            GlassEffectContainer {
                HStack {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(item.icon) { self.handler(item.id) }
                        #else
                        Button {
                            self.handler(item.id)
                        } label: {
                            Image(systemName: item.icon)
                        }
                        .buttonStyle(.glass)
                        #endif
                    }
                }
            }
        case .pair(let id, let a, let b):
            GlassEffectContainer {
                HStack(spacing: self.pairSpacing) {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(a.icon) { self.handler(a.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(b.icon) { self.handler(b.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)
                        #else
                        Button {
                            self.handler(a.id)
                        } label: {
                            Image(systemName: a.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(b.id)
                        } label: {
                            Image(systemName: b.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)
                        #endif
                    }
                }
            }
        case .trio(let id, let a, let b, let c):
            GlassEffectContainer {
                HStack(spacing: self.pairSpacing) {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(a.icon) { self.handler(a.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(b.icon) { self.handler(b.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(c.icon) { self.handler(c.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)
                        #else
                        Button {
                            self.handler(a.id)
                        } label: {
                            Image(systemName: a.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(b.id)
                        } label: {
                            Image(systemName: b.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(c.id)
                        } label: {
                            Image(systemName: c.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)
                        #endif
                    }
                }
            }
        case .quartet(let id, let a, let b, let c, let d):
            GlassEffectContainer {
                HStack(spacing: self.pairSpacing) {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(a.icon) { self.handler(a.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(b.icon) { self.handler(b.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(c.icon) { self.handler(c.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(d.icon) { self.handler(d.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)
                        #else
                        Button {
                            self.handler(a.id)
                        } label: {
                            Image(systemName: a.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(b.id)
                        } label: {
                            Image(systemName: b.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(c.id)
                        } label: {
                            Image(systemName: c.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(d.id)
                        } label: {
                            Image(systemName: d.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)
                        #endif
                    }
                }
            }

        case .zoomGroup(let id, let a, let b, let str, let c, let d):
            GlassEffectContainer {
                HStack(spacing: self.pairSpacing) {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(a.icon) { self.handler(a.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(b.icon) { self.handler(b.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        Text(str)
                            .frame(width: 72)
                            .glassEffect()
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(c.icon) { self.handler(c.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(d.icon) { self.handler(d.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)
                        #else
                        Button {
                            self.handler(a.id)
                        } label: {
                            Image(systemName: a.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(b.id)
                        } label: {
                            Image(systemName: b.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(c.id)
                        } label: {
                            Image(systemName: c.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(d.id)
                        } label: {
                            Image(systemName: d.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)
                        #endif
                    }
                }
            }
        }
    }
}
