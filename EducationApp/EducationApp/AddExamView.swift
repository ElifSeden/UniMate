import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddExamView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var subject = ""
    @State private var note = ""
    @State private var selectedDate = Date()

    var onSave: (Exam) -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Kapat Butonu
                HStack {
                    Button("Kapat") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                }

                // Başlık
                Text("Sınav Ekle")
                    .font(.largeTitle.bold())

                Text("Sınav Bilgileri")
                    .font(.headline)
                    .foregroundColor(.gray)

                // Alanlar
                VStack(spacing: 16) {
                    TextField("Ders/Konu", text: $subject)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField("Not (isteğe bağlı)", text: $note)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                // Kaydet Butonu (Gradientli)
                Button(action: {
                    let newExam = Exam(subject: subject, date: selectedDate, note: note)
                    saveExamToFirestore(newExam)
                    onSave(newExam)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sınavı Kaydet")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .disabled(subject.isEmpty)

                Spacer()
            }
            .padding()
        }
    }

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
