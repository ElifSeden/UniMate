import SwiftUI

struct MiniWeekTrackerView: View {
    let days = ["P", "S", "Ç", "P", "C", "C", "P"]
    @State private var selectedDayIndex = Calendar.current.component(.weekday, from: Date()) - 2
    @State private var completedDays: [Bool] = [true, false, false, true, false, false, true]

    var completedCount: Int {
        completedDays.filter { $0 }.count
    }

    var body: some View {
        VStack(spacing: 10) {
            // Günler
            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        Text(days[index])
                            .font(.caption)
                            .foregroundColor(.black)

                        ZStack {
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 22, height: 22)

                            if completedDays[index] {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(selectedDayIndex == index ? Color.gray.opacity(0.2) : Color.clear)
                        )
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedDayIndex = index
                            completedDays[index].toggle()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4) // 🔧 daha dar padding

            // Hedef
            VStack(spacing: 2) {
                Text("HEDEF")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(completedCount) / 6")
                    .font(.headline)
                    .bold()
            }
        }
        .padding(.top, 4) // 🔧 üst padding azaltıldı
    }
}
