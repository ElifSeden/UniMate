import SwiftUI

struct AddExamView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var subject: String = ""
    @State private var examDate: Date = Date()

    var onSave: (String, Date) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exam Details")) {
                    TextField("Subject", text: $subject)
                    DatePicker("Date", selection: $examDate, displayedComponents: [.date])
                }
            }
            .navigationTitle("Add Exam")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                onSave(subject, examDate)
                presentationMode.wrappedValue.dismiss()
            }.disabled(subject.isEmpty))
        }
    }
}

