import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddExamView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var subject = ""
    @State private var note = ""

    var date: Date
    var onSave: (Exam) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exam Info")) {
                    TextField("Subject", text: $subject)

                    DatePicker("Date", selection: .constant(date), displayedComponents: .date)
                        .disabled(true)

                    TextField("Note (optional)", text: $note)
                }

                Button(action: {
                    let newExam = Exam(subject: subject, date: date, note: note)
                    saveExamToFirestore(newExam)
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

    // 🔥 Firestore’a sınav kaydetme fonksiyonu
    func saveExamToFirestore(_ exam: Exam) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("exams")
            .document(exam.id)
            .setData(exam.toDictionary()) { error in
                if let error = error {
                    print("Firestore sınav kaydı hatası: \(error.localizedDescription)")
                } else {
                    print("Sınav başarıyla kaydedildi ✅")
                }
            }
    }
}
