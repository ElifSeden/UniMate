import SwiftUI
import FirebaseFirestore
import FirebaseAuth   // <-- Eksik olan bu!

struct EditExamView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var subject: String
    @State private var note: String
    @State private var date: Date

    var exam: Exam
    var onUpdate: (Exam) -> Void

    init(exam: Exam, onUpdate: @escaping (Exam) -> Void) {
        self.exam = exam
        self._subject = State(initialValue: exam.subject)
        self._note = State(initialValue: exam.note)
        self._date = State(initialValue: exam.date)
        self.onUpdate = onUpdate
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Exam")) {
                    TextField("Subject", text: $subject)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note", text: $note)
                }

                Button(action: {
                    let updatedExam = Exam(id: exam.id, subject: subject, date: date, note: note)
                    updateExamInFirestore(updatedExam)
                    onUpdate(updatedExam)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Edit Exam")
        }
    }

    func updateExamInFirestore(_ exam: Exam) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("exams").document(exam.id).setData(exam.toDictionary()) { error in
            if let error = error {
                print("Güncelleme hatası: \(error.localizedDescription)")
            } else {
                print("Sınav başarıyla güncellendi ✅")
            }
        }
    }
}
