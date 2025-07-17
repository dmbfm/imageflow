import SwiftUI
import Values

public struct NodeVectorInput: View {

    @Binding var value: [Double]

    public init(array: Binding<[Double]>) {
        self._value = array
    }

    public init(vector2: Binding<Vector2>) {
        self._value = vector2.array
    }

    public init(vector3: Binding<Vector3>) {
        self._value = vector3.array
    }

    public init(vector4: Binding<Vector4>) {
        self._value = vector4.array
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(self.$value.enumerated()), id: \.offset) { value in
                NodeNumberInput(value: value.element)
            }
        }
    }
}

extension Vector2 {
    public var array: [Double] {
        get {
            [self.x, self.y]
        }
        set {
            self.x = newValue[0]
            self.y = newValue[1]
        }
    }
}

extension Vector3 {
    public var array: [Double] {
        get {
            [self.x, self.y, self.z]
        }
        set {
            self.x = newValue[0]
            self.y = newValue[1]
            self.z = newValue[2]
        }
    }
}

extension Vector4 {
    public var array: [Double] {
        get {
            [self.x, self.y, self.z, self.w]
        }
        set {
            self.x = newValue[0]
            self.y = newValue[1]
            self.z = newValue[2]
            self.w = newValue[3]
        }
    }
}

#Preview("Array") {
    @Previewable @State var value: [Double] = [0, 1, 2]
    VStack {
        NodeVectorInput(array: $value)
    }
    .border(.red)
    .padding(80)
}

#Preview("Vector2") {
    @Previewable @State var value = Vector2(x: 1.0, y: 2.0)
    VStack {
        NodeVectorInput(vector2: $value)
    }
    .border(.red)
    .padding(80)
}

#Preview("Vector3") {
    @Previewable @State var value = Vector3(x: 1.0, y: 2.0, z: 3.0)
    VStack {
        NodeVectorInput(vector3: $value)
    }
    .border(.red)
    .padding(80)
}

#Preview("Vector4") {
    @Previewable @State var value = Vector4(x: 1.0, y: 2.0, z: 3.0, w: 4.0)
    VStack {
        NodeVectorInput(vector4: $value)
    }
    .border(.red)
    .padding(80)
}
