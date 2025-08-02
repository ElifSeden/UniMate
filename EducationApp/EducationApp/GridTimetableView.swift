import SwiftUI

struct GridTimetableView: View {
    let days = ["Pzt", "Sal", "Çar", "Per", "Cum"]

    let hours = Array(7...18)
    @Binding var courses: [Course]

    @State private var selectedCourse: Course? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Gün başlıkları
            HStack(spacing: 0) {
                Text("").frame(width: 40)
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }

            // Saat satırları
            ForEach(hours, id: \.self) { hour in
                HStack(spacing: 0) {
                    Text("\(hour)")
                        .frame(width: 40)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)

                    ForEach(days, id: \.self) { day in
                        let courseList = coursesAt(day: day, hour: hour)

                        ZStack {
                            Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 1)

                            if !courseList.isEmpty {
                                VStack(spacing: 2) {
                                    ForEach(courseList.prefix(2)) { course in
                                        Text(course.name)
                                            .font(.caption2)
                                            .padding(2)
                                            .frame(maxWidth: .infinity)
                                            .background(course.color)
                                            .cornerRadius(4)
                                            .foregroundColor(.white)
                                            .onTapGesture {
                                                selectedCourse = course
                                            }
                                    }

                                    if courseList.count > 2 {
                                        Text("+\(courseList.count - 2) more")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(2)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 30)
                    }
                }
            }
        }
        .padding()
        .sheet(item: $selectedCourse) { selected in
            EditCourseView(course: selected) { updatedCourse in
                if let index = courses.firstIndex(where: { $0.id == updatedCourse.id }) {
                    courses[index] = updatedCourse
                }
            } onDelete: {
                courses.removeAll { $0.id == selected.id }
            }
        }
    }

    // ✅ Aynı hücreye düşen tüm dersleri bulur (gün adı eşleştirme eklendi)
    func coursesAt(day: String, hour: Int) -> [Course] {
        return courses.filter {
            $0.day == gunAdiTam(day) && $0.hour == hour
        }
    }

    func gunAdiTam(_ kisa: String) -> String {
        switch kisa {
        case "Pzt": return "Pazartesi"
        case "Sal": return "Salı"
        case "Çar": return "Çarşamba"
        case "Per": return "Perşembe"
        case "Cum": return "Cuma"
        default: return ""
        }
    }
}
