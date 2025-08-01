import SwiftUI

struct ZamanYonetimiView: View {
    @EnvironmentObject var usageTracker: AppUsageTracker
    
    // UI için editable saat & dakika
    @State private var limitHours: Int = 0
    @State private var limitMinutes: Int = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Bugünkü Kullanım Süreniz")
                .font(.title2)
                .bold()
            
            Text(formatTime(usageTracker.totalSecondsToday))
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.blue)
            
            GroupBox("Günlük Süre Limiti") {
                HStack {
                    Stepper("\(limitHours) saat", value: $limitHours, in: 0...24)
                    Stepper("\(limitMinutes) dk", value: $limitMinutes, in: 0...59)
                }
                .padding(.vertical, 8)
                .onChange(of: limitHours) { _ in updateLimit() }
                .onChange(of: limitMinutes) { _ in updateLimit() }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Zaman Yönetimi")
        .onAppear {
            // Mevcut limiti state'e yükle
            let totalSec = Int(usageTracker.dailyLimitSeconds)
            limitHours = totalSec / 3600
            limitMinutes = (totalSec / 60) % 60
            
            // Bildirim izinlerini yeniden hatırlat
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                }
            }
        }
    }
    
    private func updateLimit() {
        let newLimit = TimeInterval(limitHours * 3600 + limitMinutes * 60)
        usageTracker.dailyLimitSeconds = newLimit
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let hours = minutes / 60
        let rem = minutes % 60
        return "\(hours) saat \(rem) dakika"
    }
}
