import SwiftUI

struct MiniWeekTrackerView: View {
    @Binding var selectedDate: Date
    @Binding var weekOffset: Int

    private let calendar = Calendar.current

    private var weekDates: [Date] {
        guard let baseWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: Date()),
              let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: baseWeek) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text("")
                    .frame(width: 24)
                ForEach(weekDates, id: \.self) { date in
                    let weekday = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                    Text(weekday)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                Text("")
                    .frame(width: 24)
            }

            
            HStack(spacing: 12) {
             
                Button(action: {
                    weekOffset -= 1
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 32)
                }

             
                ForEach(weekDates, id: \.self) { date in
                    let isToday = calendar.isDateInToday(date)
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let day = calendar.component(.day, from: date)

                    ZStack {
                        Circle()
                            .fill(
                                isSelected ? Color.blue :
                                (isToday ? Color(.systemGray5) : Color.clear)
                            )
                            .frame(width: 32, height: 32)

                        Text("\(day)")
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .black)
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                }



               
                Button(action: {
                    weekOffset += 1
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 32)
                }
            }
        }
        .padding(.horizontal)
    }
}
