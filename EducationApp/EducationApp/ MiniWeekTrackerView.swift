import SwiftUI

struct MiniWeekTrackerView: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private var weekDates: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: Date()) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(weekDates, id: \.self) { date in
                let isToday = calendar.isDateInToday(date)
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let daySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                let dayNumber = calendar.component(.day, from: date)

                VStack(spacing: 4) {
                    Text(daySymbol)
                        .font(.caption)
                        .foregroundColor(.black)

                    Text("\(dayNumber)")
                        .font(.system(size: 14, weight: isToday ? .bold : .regular))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isToday ? Color.red : (isSelected ? Color.gray.opacity(0.2) : Color.clear))
                        )
                        .foregroundColor(isToday ? .white : .black)
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal)
    }
}
