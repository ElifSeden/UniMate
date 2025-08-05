import SwiftUI

struct Course: Identifiable {
    var id: UUID
    var name: String
    var day: String
    var hour: Int
    var location: String
    var color: Color

    init(id: UUID = UUID(), name: String, day: String, hour: Int, location: String, color: Color) {
        self.id = id
        self.name = name
        self.day = day
        self.hour = hour
        self.location = location
        self.color = color
    }
}

let sampleCourses: [Course] = [
    Course(name: "CMPE 223", day: "Wednesday", hour: 10, location: "D832", color: .yellow),
    Course(name: "PHYS 102", day: "Wednesday", hour: 11, location: "DB106", color: .red),
    Course(name: "SENG 218", day: "Monday", hour: 12, location: "D206", color: .blue),
    Course(name: "MATH 240", day: "Wednesday", hour: 13, location: "D030", color: .green),
    Course(name: "SENG 212", day: "Friday", hour: 14, location: "G103", color: .purple)
]
