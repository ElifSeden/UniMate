import SwiftUI

struct EditCourseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String
    @State private var hour: Int
    @State private var day: String
    let course: Course
    let onUpdate: (Course) -> Void
    let onDelete: () -> Void

    init(course: Course, onUpdate: @escaping (Course) -> Void, onDelete: @escaping () -> Void) {
        self.course = course
        self._name = State(initialValue: course.name)
        self._hour = State(initialValue: course.hour)
        self._day = State(initialValue: course.day)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Course")) {
                    TextField("Name", text: $name)
                    TextField("Day (e.g. Mon)", text: $day)
                    Stepper("Hour: \(hour)", value: $hour, in: 7...18)
                }

                Section {
                    Button("Save Changes") {
                        let updated = Course(id: course.id, name: name, day: day, hour: hour, color: course.color)
                        onUpdate(updated)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)

                    Button("Delete Course") {
                        onDelete()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Course")
        }
    }
}
