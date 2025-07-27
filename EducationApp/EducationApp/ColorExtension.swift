import SwiftUI

// Ortak renk uzantısı
extension Color {
    static func random() -> Color {
        let colors: [Color] = [
            .red, .blue, .green, .purple, .yellow, .orange, .pink
        ]
        return colors.randomElement() ?? .blue
    }
}
