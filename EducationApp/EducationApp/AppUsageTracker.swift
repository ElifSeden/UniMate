import Foundation
import SwiftUI

class AppUsageTracker: ObservableObject {
    @Published var totalSecondsToday: TimeInterval = 0
    private var sessionStart: Date?

    init() {
        loadSavedTime()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc func appDidBecomeActive() {
        sessionStart = Date()
    }

    @objc func appDidEnterBackground() {
        guard let start = sessionStart else { return }
        let sessionTime = Date().timeIntervalSince(start)
        totalSecondsToday += sessionTime
        saveTime()
    }

    func saveTime() {
        UserDefaults.standard.set(totalSecondsToday, forKey: "totalSecondsToday")
    }

    func loadSavedTime() {
        totalSecondsToday = UserDefaults.standard.double(forKey: "totalSecondsToday")
    }
}
