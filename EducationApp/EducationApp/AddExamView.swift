import SwiftUI

struct AddExamView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var subject = ""
    @State private var date = Date()
    @State private var note = ""

    var onSave: (Exam) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exam Info")) {
                    TextField("Subject", text: $subject)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                }

                Button(action: {
                    let newExam = Exam(subject: subject, date: date, note: note)
                    onSave(newExam)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Exam")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(subject.isEmpty)
            }
            .navigationTitle("Add Exam")
        }
    }
}
