import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

struct UserProfile {
    let name: String
    let surname: String
    let department: String
    let universityName: String
}

struct HomeView: View {
    @Binding var selectedTab: Int

    @State private var points: Int = 300
    @State private var selectedDate = Date()
    @State private var exams: [Exam] = []
    @State private var showingAllExams = false
    @State private var editingExam: Exam? = nil
    @State private var showingEditExam = false
    @State private var greetingText: String = ""
    private var fullGreeting: String {
        guard let name = userProfile?.name, !name.isEmpty else { return "" }
        return "Hoşgeldin \(name)!"
    }

    var upcomingExams: [Exam] {
        exams.sorted { $0.date < $1.date }
    }

    @State private var showingAddExam = false
    @State private var showingTimetable = false
    @State private var showingProfile = false
    @State private var showingMoodCheck = false
    @State private var showingAIDetector = false
    @State private var showingParaphrase = false
    @State private var showingTodoList = false

    @State private var courses: [Course] = sampleCourses
    @State private var weekOffset: Int = 0
    @State private var userProfile: UserProfile? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                ZStack {
                    Color.blue
                        .ignoresSafeArea(edges: .top)
                    
                    HStack(spacing: 12) {
                        Text(greetingText)
                            .font(.title).bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        NavigationLink(destination: MenuView(selectedTab: $selectedTab)) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 41, height: 41)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    .padding(.bottom, 20)
                }
                .frame(height: 56)
                .offset(y: -20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        MiniWeekTrackerView(selectedDate: $selectedDate, weekOffset: $weekOffset)
                        
                        Button(action: {
                            showingAddExam = true
                        }) {
                            Text("Sınav Ekle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        
                        if !exams.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Upcoming Exams")
                                        .font(.headline)
                                    Spacer()
                                    Button("See All") {
                                        showingAllExams = true
                                    }
                                    .font(.subheadline)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(upcomingExams.prefix(3)) { exam in
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(exam.subject)
                                                    .font(.body.bold())
                                                Text(exam.date, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                if !exam.note.isEmpty {
                                                    Text(exam.note)
                                                        .font(.callout)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding()
                                            .frame(width: 160)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                        HStack(spacing: 12) {
                            Button(action: {
                                showingMoodCheck = true
                            }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("MoodCheck")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    Text("Nasıl hissediyorsun? AI önerilerini al 💡")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    Image(systemName: "face.smiling.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 28))
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.45, height: 140)
                                .background(
                                    LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                            }
                            .sheet(isPresented: $showingMoodCheck) {
                                MoodCheckFullView()
                            }
                            
                            Button(action: {
                                showingAIDetector = true
                            }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("AI Detector")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    Text("Metni yapıştır, AI oranını öğren")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 28))
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.45, height: 140)
                                .background(
                                    LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                            }
                            .sheet(isPresented: $showingAIDetector) {
                                AIDetectorView()
                            }
                        }
                        
                        HStack(spacing: 12) {
                            
                            Button(action: {
                                showingParaphrase = true
                            }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Paraphrase")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    Text("AI çıkmasın, öğrenci gibi yaz")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    Image(systemName: "text.append")
                                        .foregroundColor(.white)
                                        .font(.system(size: 28))
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.45, height: 140)
                                .background(
                                    LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                            }
                            .sheet(isPresented: $showingParaphrase) {
                                ParaphraseView()
                            }
                            Button(action: {
                                showingTodoList = true
                            }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Görevlerim")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    Text("Günlük görevlerini not al ✍️")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.white)
                                        .font(.system(size: 28))
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.45, height: 140)
                                .background(
                                    LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                            }
                            .sheet(isPresented: $showingTodoList) {
                                TodoListView()
                            }
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Haftalık Program")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingTimetable = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .padding(10)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            
                            GridTimetableView(courses: $courses)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchUserProfile()
                fetchExams()
                requestNotificationPermission()
            }
            .sheet(isPresented: $showingAddExam) {
                AddExamView { newExam in
                    saveExamToFirestore(newExam)
                    exams.append(newExam)
                    scheduleExamNotification(title: newExam.subject, examDate: newExam.date)
                }
            }
            .sheet(isPresented: $showingTimetable) {
                AddNewCourseView { newCourse in
                    courses.append(newCourse)
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(selectedTab: $selectedTab)
            }
            .sheet(isPresented: $showingAllExams) {
              
                NavigationView {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(upcomingExams) { exam in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(exam.subject).font(.headline)
                                    Text(exam.date, style: .date).foregroundColor(.gray)
                                    if !exam.note.isEmpty {
                                        Text(exam.note)
                                            .font(.callout)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Button("Edit") {
                                            
                                            editingExam = exam
                                        }
                                        .padding(.trailing)
                                        
                                        Button(role: .destructive) {
                                            deleteExamFromFirestore(exam)
                                        } label: {
                                            Text("Delete")
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                    .navigationTitle("All Exams")
                    .navigationBarTitleDisplayMode(.inline)
                   
                    .sheet(item: $editingExam) { exam in
                        EditExamView(exam: exam) { updated in
                         
                            updateExamInFirestore(updated)
                           
                            if let idx = exams.firstIndex(where: { $0.id == updated.id }) {
                                exams[idx] = updated
                            }
                            
                            editingExam = nil
                        }
                    }
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            } else {
                print("Bildirim izni verildi mi? \(granted)")
            }
        }
    }

    private func scheduleExamNotification(title: String, examDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sınav Hatırlatması 📚"
        content.body = "\(title) sınavın yarın! Hazır mısın?"
        content.sound = .default

        let reminderDate = examDate.addingTimeInterval(-86400)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlama hatası: \(error.localizedDescription)")
            }
        }
    }

    private func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let surname = data?["surname"] as? String ?? ""
              
                self.userProfile = UserProfile(
                    name: name,
                    surname: surname,
                    department: data?["department"] as? String ?? "",
                    universityName: data?["universityName"] as? String ?? ""
                )
              
                DispatchQueue.main.async {
                    self.typeWriter()
                }
            } else {
                print("Kullanıcı profili bulunamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }

    private func fetchExams() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).collection("exams").getDocuments { snapshot, error in
            if let error = error {
                print("Sınavlar alınamadı: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            self.exams = documents.compactMap { doc -> Exam? in
                let data = doc.data()
                guard let subject = data["subject"] as? String,
                      let timestamp = data["date"] as? Timestamp else { return nil }

                let note = data["note"] as? String ?? ""
                return Exam(id: doc.documentID, subject: subject, date: timestamp.dateValue(), note: note)
            }
        }
    }

    private func saveExamToFirestore(_ exam: Exam) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let examData: [String: Any] = [
            "subject": exam.subject,
            "date": Timestamp(date: exam.date),
            "note": exam.note
        ]

        db.collection("users").document(uid).collection("exams").document(exam.id).setData(examData) { error in
            if let error = error {
                print("Sınav kaydedilemedi: \(error.localizedDescription)")
            } else {
                print("Sınav başarıyla kaydedildi ✅")
            }
        }
    }

    private func deleteExamFromFirestore(_ exam: Exam) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("exams").document(exam.id).delete { error in
            if let error = error {
                print("Sınav silinemedi: \(error.localizedDescription)")
            } else {
                exams.removeAll { $0.id == exam.id }
            }
        }
    }
    private func typeWriter() {
        greetingText = ""
        let chars = Array(fullGreeting)
        for i in chars.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                greetingText.append(chars[i])
            }
        }
    }


    private func updateExamInFirestore(_ exam: Exam) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("exams").document(exam.id).updateData([
            "subject": exam.subject,
            "date": Timestamp(date: exam.date),
            "note": exam.note
        ]) { error in
            if let error = error {
                print("Sınav güncellenemedi: \(error.localizedDescription)")
            }
        }
    }
    
}
