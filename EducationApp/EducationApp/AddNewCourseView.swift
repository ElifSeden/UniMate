import SwiftUI

struct AddNewCourseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var selectedDay = "Monday"
    @State private var selectedHour = 9

    var onSave: (Course) -> Void

    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let hours = Array(7...18)

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Info")) {
                    TextField("Course Name", text: $name)
                    TextField("Location", text: $location)

                    Picker("Day", selection: $selectedDay) {
                        ForEach(days, id: \.self) { Text($0) }
                    }

                    Picker("Hour", selection: $selectedHour) {
                        ForEach(hours, id: \.self) { Text("\($0):00") }
                    }
                }

                Button(action: {
                    let newCourse = Course(
                        name: name,
                        day: selectedDay,
                        hour: selectedHour,
                        location: location,
                        color: Color.random()
                    )
                    onSave(newCourse)
                    dismiss()
                }) {
                    Text("Save Course")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}



