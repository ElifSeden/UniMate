import SwiftUI

struct ZamanYonetimiView: View {
    @EnvironmentObject var usageTracker: AppUsageTracker


    var body: some View {
        VStack(spacing: 20) {
            Text("Bugünkü Kullanım Süreniz")
                .font(.title2)
                .bold()

            Text(formatTime(usageTracker.totalSecondsToday))
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.blue)

            Spacer()
        }
        .padding()
        .navigationTitle("Zaman Yönetimi")
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours) saat \(remainingMinutes) dakika"
    }
}
