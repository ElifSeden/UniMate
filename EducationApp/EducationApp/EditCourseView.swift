import SwiftUI

struct EditCourseView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String
    @State private var day: String
    @State private var hour: Int
    @State private var location: String

    var course: Course
    var onUpdate: (Course) -> Void
    var onDelete: () -> Void

    init(course: Course, onUpdate: @escaping (Course) -> Void, onDelete: @escaping () -> Void) {
        self.course = course
        self._name = State(initialValue: course.name)
        self._day = State(initialValue: course.day)
        self._hour = State(initialValue: course.hour)
        self._location = State(initialValue: course.location)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ders Bilgisi")) {
                    TextField("Ders Adı", text: $name)
                    TextField("Gün (ör: Pazartesi)", text: $day)
                    TextField("Yer", text: $location)
                    Stepper("Saat: \(hour):00", value: $hour, in: 7...18)
                }

                Section {
                    Button("Değişiklikleri Kaydet") {
                        let updated = Course(
                            id: course.id,
                            name: name,
                            day: day,
                            hour: hour,
                            location: location,
                            color: course.color
                        )

                        onUpdate(updated)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)

                    Button("Dersi Sil") {
                        onDelete()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Dersi Düzenle")
        }
    }
}
