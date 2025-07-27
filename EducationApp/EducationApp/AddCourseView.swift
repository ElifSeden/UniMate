import SwiftUI

struct AddCourseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var selectedDay = "Mon"
    @State private var selectedHour = 9

    var onAdd: (Course) -> Void

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let hours = Array(9...16)

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Info")) {
                    TextField("Course Name", text: $name)
                    TextField("Location", text: $location)

                    Picker("Day", selection: $selectedDay) {
                        ForEach(days, id: \.self) { day in
                            Text(day)
                        }
                    }

                    Picker("Hour", selection: $selectedHour) {
                        ForEach(hours, id: \.self) { hour in
                            Text("\(hour):00")
                        }
                    }
                }
            }
            .navigationTitle("Add Course")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newCourse = Course(
                            name: name,
                            day: selectedDay,
                            hour: selectedHour,
                            location: location,
                            color: Color.random()
                        )
                        onAdd(newCourse)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


