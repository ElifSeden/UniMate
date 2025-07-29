import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications // ✅ Bildirim için eklendi

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

    var upcomingExams: [Exam] {
        exams.sorted { $0.date < $1.date }
    }

    @State private var showingAddExam = false
    @State private var showingTimetable = false
    @State private var showingProfile = false
    @State private var courses: [Course] = sampleCourses
    @State private var weekOffset: Int = 0
    @State private var userProfile: UserProfile? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hi, \(userProfile?.name ?? "User")")
                                .font(.title)
                                .bold()

                            Text("")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            showingProfile = true
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    // MARK: - Weekly Calendar View
                    MiniWeekTrackerView(selectedDate: $selectedDate, weekOffset: $weekOffset)

                    // MARK: - Add Exam
                    Button(action: {
                        showingAddExam = true
                    }) {
                        Text("Add Exam")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }

                    // MARK: - En Yakın 3 Sınav
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

                    // MARK: - Points Card
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(points) Points")
                                .font(.title2.bold())
                            Text("Cross 500 this week to get a free\n1-on-1 class")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            // test başlat
                        }) {
                            Text("Take test now")
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)

                    // MARK: - Weekly Schedule
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weekly Schedule")
                                    .font(.title2.bold())
                                Text("Your weekly courses")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                showingTimetable = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)

                        GridTimetableView(courses: $courses)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchUserProfile()
                fetchExams()
                requestNotificationPermission() // ✅ Bildirim izni istenir
            }
            .sheet(isPresented: $showingAddExam) {
                AddExamView(date: selectedDate) { newExam in
                    saveExamToFirestore(newExam)
                    exams.append(newExam)
                    scheduleExamNotification(title: newExam.subject, examDate: newExam.date) // ✅ Bildirim kur
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
                                    Text(exam.subject)
                                        .font(.headline)
                                    Text(exam.date, style: .date)
                                        .foregroundColor(.gray)
                                    if !exam.note.isEmpty {
                                        Text(exam.note)
                                            .font(.callout)
                                            .foregroundColor(.secondary)
                                    }

                                    HStack {
                                        Button("Edit") {
                                            editingExam = exam
                                            showingEditExam = true
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
                }
            }
            .sheet(item: $editingExam) { exam in
                EditExamView(exam: exam) { updatedExam in
                    updateExamInFirestore(updatedExam)
                    if let index = exams.firstIndex(where: { $0.id == updatedExam.id }) {
                        exams[index] = updatedExam
                    }
                }
            }
        }
    }

    // ✅ Bildirim izni isteyen fonksiyon
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            } else {
                print("Bildirim izni verildi mi? \(granted)")
            }
        }
    }

    // ✅ Bildirimi 1 gün öncesine planlayan fonksiyon
    private func scheduleExamNotification(title: String, examDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sınav Hatırlatması 📚"
        content.body = "\(title) sınavın yarın! Hazır mısın?"
        content.sound = .default

        let reminderDate = examDate.addingTimeInterval(-86400) // 1 gün önce (86400 saniye)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlama hatası: \(error.localizedDescription)")
            }
        }
    }

    // 🔄 Firestore işlemleri — senin orijinal kodun değişmeden:
    private func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.userProfile = UserProfile(
                    name: data?["name"] as? String ?? "",
                    surname: data?["surname"] as? String ?? "",
                    department: data?["department"] as? String ?? "",
                    universityName: data?["universityName"] as? String ?? ""
                )
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
