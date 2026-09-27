import SwiftUI


public struct TrialPillView: View {
    
    public struct VM: Equatable {
        var remainingDays: Int
        
        public init(remainingDays: Int) {
            self.remainingDays = remainingDays
        }
    }
    
    let vm: VM
    let onClick: (() -> ())?
    
    var expired: Bool {
        self.vm.remainingDays <= 0
    }
    
    var message: String {
        if self.expired {
            "Your trial has expired! Support ImageFlow development and"
        } else {
            "Remaining days in trial: \(self.vm.remainingDays)"
        }
    }
    
    var spacing: CGFloat {
        self.expired ? 4.0 : 4.0
    }
    
    public init(vm: VM, onClick: (() -> ())? = nil) {
        self.vm = vm
        self.onClick = onClick
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            Text(self.message)
                .padding(.leading, 6)
            Button("Get the Full Version") {
                self.onClick?()
            }
            .controlSize(.small)
            .buttonBorderShape(.capsule)
        }
        .font(.caption2)
        .padding(.horizontal, 3)
        .padding(.vertical, 4)
        .foregroundStyle(.black)
        .background {
            Color.orange
        }
        .clipShape(Capsule())
    }
}


#Preview {
    VStack {
        TrialPillView(vm: .init(remainingDays: 2))
        TrialPillView(vm: .init(remainingDays: 0))
    }
    .frame(minWidth: 400, minHeight: 400)
    
}
