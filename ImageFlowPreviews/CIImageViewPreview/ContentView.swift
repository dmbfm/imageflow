//
//  ContentView.swift
//  CIImageViewPreview
//
//  Created by Daniel Fortes on 11/05/26.
//

import CIImageView
import SwiftUI

class ViewportCache<ID: Hashable> {

  private var items: [ID: CGRect] = [:]
  private var locked: Bool = false

  var _items: [ID: CGRect] { self.items }

  func set(_ id: ID, _ value: CGRect) {
    if !self.locked {
      self.items[id] = value
    }
  }

  func get(_ id: ID) -> CGRect? {
    self.items[id]
  }

  func lock() {
    self.locked = true
  }

  func unlock() {
    self.locked = false
  }

  func whileLocked(_ perform: () -> Void) {
    self.lock()
    perform()
    self.unlock()
  }
}

#if os(macOS)
  class ViewController: NSViewController, CIImageScrollXViewDelegate {

    var ciImageView: CIImageScrollXView!

    var viewportBinding: Binding<CGRect>?
    var cacheBinding: Binding<[Int: CGRect]>?

    let nsImages: [NSImage] = [
      .init(named: "01")!,
      .init(named: "02")!,
      .init(named: "03")!,
    ]

    var ciImages: [CIImage] = []

    var cache: ViewportCache<Int> = .init()

    var currentImage: Int = -1 {
      didSet {
        if self.currentImage != oldValue {

          self.cache.whileLocked {
            self.ciImageView.image = self.ciImages[self.currentImage]
          }

          if let cached = self.cache.get(self.currentImage) {
            self.ciImageView.scrollView.contentView.bounds = cached
          } else {
            Task {
              self.ciImageView.dispatch(.zoomToFit(animate: false))
            }
          }
        }
      }
    }

    override func loadView() {
      self.ciImageView = .init(frame: .zero, configuration: .init())
      self.view = ciImageView
    }

    override func viewDidLoad() {
      self.ciImages = self.nsImages.map({ image in
        return .init(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
      })
      //        self.currentImage = 0
      self.ciImageView.delegate = self
    }

    // MARK: - CIImageScrollViewDelegate

    func ciImageScrollViewViewportDidChange(_ view: CIImageScrollXView, _ viewport: CGRect) {

      self.cache.set(self.currentImage, viewport)

      if let v = self.viewportBinding {
        Task {
          v.wrappedValue = viewport
        }
      }

      if let v = self.cacheBinding {
        Task {
          v.wrappedValue = self.cache._items
        }
      }
    }

    func ciImageScrollViewZoomDidChange(_ view: CIImageScrollXView, _ zoom: CGFloat) {
    }
  }

  struct MainView: NSViewControllerRepresentable {

    @Binding var currentImage: Int
    @Binding var viewport: CGRect
    @Binding var cache: [Int: CGRect]

    func makeNSViewController(context: Context) -> ViewController {
      let vc = ViewController()
      //        vc.currentImage = self.currentImage
      return vc
    }

    func updateNSViewController(_ vc: ViewController, context: Context) {
      if vc.currentImage != self.currentImage {
        vc.currentImage = self.currentImage
      }
      vc.viewportBinding = self.$viewport
      vc.cacheBinding = self.$cache
    }
  }

#endif

struct ContentView: View {

  @State var currentImage: Int = 0
  @State var viewport: CGRect = .zero
  @State var cache: [Int: CGRect] = [:]

  let formatter: NumberFormatter = {
    let f = NumberFormatter()
    f.maximumFractionDigits = 2
    return f
  }()

  var originText: String {
    let o = self.viewport.origin
    return "\(formatter.string(for: o.x)!), \(formatter.string(for: o.y)!)"
  }

  var sizeText: String {
    let o = self.viewport.size
    return "\(formatter.string(for: o.width)!), \(formatter.string(for: o.height)!)"
  }

  var body: some View {
    VStack {
      HStack {
        MainView(currentImage: self.$currentImage, viewport: self.$viewport, cache: self.$cache)
          .border(.black)

        VStack {
          //                    Form {
          Picker("Image", selection: self.$currentImage) {
            Text("0").tag(0)
            Text("1").tag(1)
            Text("2").tag(2)
          }

          LabeledContent {
            Text(self.originText)
          } label: {
            Text("Origin")
          }

          LabeledContent {
            Text(self.sizeText)
          } label: {
            Text("Size")
          }

          ForEach(Array(self.cache.keys.sorted()), id: \.self) { i in
            VStack {
              Text("\(i)")
              Text("\(self.cache[i], default: "nil")")
            }
          }

          //                    }
          //                    .formStyle(.columns)
          Spacer()
        }
        .frame(width: 200)
      }

    }
    .padding()
  }
}

#Preview {
  ContentView()
}
