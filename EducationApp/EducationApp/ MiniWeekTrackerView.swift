import SwiftUI

struct MiniWeekTrackerView: View {
    let days = ["P", "S", "Ç", "P", "C", "C", "P"]
    @State private var selectedDayIndex = Calendar.current.component(.weekday, from: Date()) - 2
    @State private var completedDays: [Bool] = [true, false, true, true, false, false, false]

    var completedCount: Int {
        completedDays.filter { $0 }.count
    }

    var body: some View {
        HStack {
            HStack(spacing: 14) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        Text(days[index])
                            .font(.subheadline)
                            .foregroundColor(.black)

                        ZStack {
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 24, height: 24)

                            if completedDays[index] {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                            }
                        }
                        .background {
                            if selectedDayIndex == index {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                            }
                        }

                        .onTapGesture {
                            selectedDayIndex = index
                            completedDays[index].toggle()
                        }
                    }
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("HEDEF")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(completedCount) / 6")
                    .font(.headline)
                    .bold()
            }
        }
        .padding(.horizontal)
    }
}
