import Foundation

@MainActor
public class TrialManager {

    public var trialStartDate: Date
    public var trialPeriod: Double = 7.0 * 24.0 * 60.0 * 60.0

    public static let key = "com.dmbfm.imageflow.macos-trial.start-date"
    public static let shared = TrialManager()

    public var trialEnded: Bool {
        Date.now.timeIntervalSince(self.trialStartDate) >= trialPeriod
    }

    public var remaining: TimeInterval {
        trialPeriod - Date.now.timeIntervalSince(self.trialStartDate)
    }

    public var daysRemaining: Int {
        if self.remaining < 0 {
            0
        } else {
            (Int(self.remaining) / (60 * 60 * 24)) + 1
        }
    }

    public init() {
        if UserDefaults.standard.object(forKey: Self.key) == nil {
            UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: Self.key)
        }
        let t = UserDefaults.standard.double(forKey: Self.key)
        UserDefaults.standard.set(t, forKey: Self.key)
        self.trialStartDate = Date(timeIntervalSince1970: t)
    }

    public init(startDate date: Date) {
        self.trialStartDate = date
    }

    public init(timeIntervalSince1970 t: TimeInterval) {
        self.trialStartDate = Date(timeIntervalSince1970: t)
    }

    public func resetTrial() {
        UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: Self.key)
        let t = UserDefaults.standard.double(forKey: Self.key)
        UserDefaults.standard.set(t, forKey: Self.key)
        self.trialStartDate = Date(timeIntervalSince1970: t)
    }
}

