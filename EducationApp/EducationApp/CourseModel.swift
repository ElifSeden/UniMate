import SwiftUI

struct Course: Identifiable {
    let id = UUID()
    let name: String
    let day: String
    let hour: Int
    let location: String
    let color: Color
}

// Sadece burada tanımlı olsun. Başka dosyada TANIMLAMA!
let sampleCourses: [Course] = [
    Course(name: "CMPE 223", day: "Wednesday", hour: 10, location: "D832", color: .yellow),
    Course(name: "PHYS 102", day: "Wednesday", hour: 11, location: "DB106", color: .red),
    Course(name: "SENG 218", day: "Monday", hour: 12, location: "D206", color: .blue),
    Course(name: "MATH 240", day: "Wednesday", hour: 13, location: "D030", color: .green),
    Course(name: "SENG 212", day: "Friday", hour: 14, location: "G103", color: .purple)
]
