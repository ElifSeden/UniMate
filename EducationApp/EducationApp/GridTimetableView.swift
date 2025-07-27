import SwiftUI

struct GridTimetableView: View {
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    let hours = Array(7...18)
    let courses: [Course]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("") // sol boşluk
                    .frame(width: 40)
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }

            ForEach(hours, id: \.self) { hour in
                HStack(spacing: 0) {
                    Text("\(hour)")
                        .frame(width: 40)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)

                    ForEach(days, id: \.self) { day in
                        let course = courseAt(day: day, hour: hour)
                        ZStack {
                            Rectangle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            if let course = course {
                                Text(course.name)
                                    .font(.caption2)
                                    .padding(4)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(course.color)
                                    .cornerRadius(4)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 30)
                    }
                }
            }
        }
        .padding()
    }

    func courseAt(day: String, hour: Int) -> Course? {
        return courses.first {
            $0.day.prefix(3).lowercased() == day.lowercased() && $0.hour == hour
        }
    }
}
