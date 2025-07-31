import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

struct MoodCheckFullView: View {
    @Environment(\.dismiss) var dismiss

    // Ruh hali & AI
    @State private var selectedMood: String? = nil
    @State private var saveStatus: String? = nil
    @State private var moodComment: String = ""
    @State private var aiSuggestions: [String] = []
    @State private var isLoadingSuggestions = false
    @State private var showMotivation = false
    @State private var motivationMessage = ""

    // Görevler & Puan
    @State private var userTasks: [String] = []
    @State private var newTaskText: String = ""
    @State private var showAddTaskAlert = false

    @State private var completedTasks: Set<String> = []
    @State private var points: Int = 0

    // Rozetler
    @State private var earnedBadges: [String] = []

    let moods = ["😄", "🙂", "😐", "😔", "😢"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Nasıl hissediyorsun?")
                        .font(.title)
                        .bold()

                    // Emoji seçim
                    HStack(spacing: 16) {
                        ForEach(moods, id: \.self) { mood in
                            ZStack {
                                Circle()
                                    .fill(selectedMood == mood ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                Text(mood)
                                    .font(.system(size: 32))
                            }
                            .onTapGesture {
                                selectedMood = mood
                                saveMoodToFirestore(mood)
                            }
                        }
                    }

                    // AI Önerisi
                    if let mood = selectedMood {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Önerisi \u{1F4A1}").font(.headline)
                            Text(getSuggestion(for: mood))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Yorum & AI öneri
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bugünkü modunu kelimelere dökmek ister misin?").font(.headline)
                        TextField("Bugün çok stresliyim...", text: $moodComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: getAISuggestions) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("AI önerisi al")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(moodComment.trimmingCharacters(in: .whitespaces).isEmpty || isLoadingSuggestions)

                        if isLoadingSuggestions {
                            ProgressView("AI düşünüyor...")
                        }

                        if !aiSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("AI'dan Öneriler \u{1F9E0}").font(.headline)
                                ForEach(aiSuggestions, id: \.self) { suggestion in
                                    Text("• \(suggestion)").font(.subheadline)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }

                    // Görev kutuları
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Bugünlük Görevler ✅").font(.headline)
                            Spacer()
                            Button(action: { showAddTaskAlert = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .alert("Yeni Görev Ekle", isPresented: $showAddTaskAlert) {
                                TextField("Yeni görev", text: $newTaskText)
                                Button("Ekle", action: addNewTask)
                                Button("İptal", role: .cancel) {}
                            }
                        }

                        if userTasks.isEmpty {
                            Text("Henüz görev eklenmedi.")
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }

                        ForEach(userTasks, id: \.self) { task in
                            HStack {
                                Button(action: {
                                    toggleTask(task)
                                }) {
                                    Image(systemName: completedTasks.contains(task) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(completedTasks.contains(task) ? .green : .gray)
                                        .font(.title2)
                                }

                                Text(task)
                                    .strikethrough(completedTasks.contains(task))
                                    .foregroundColor(completedTasks.contains(task) ? .gray : .primary)
                            }
                            .padding(.vertical, 4)
                        }

                        Text("Toplam Puan: \(points)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Rozetler
                    if !earnedBadges.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kazanılan Rozetler \u{1F3C5}")
                                .font(.headline)
                            ForEach(earnedBadges, id: \.self) { badge in
                                Text("• \(badge)")
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(12)
                    }

                    // Motivasyon
                    if showMotivation {
                        VStack(alignment: .leading) {
                            Text("Motivasyon Mesajı \u{1F4DD}").font(.headline)
                            Text(motivationMessage)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(12)
                    }

                    // Kayıt durumu
                    if let status = saveStatus {
                        Text(status)
                            .font(.footnote)
                            .foregroundColor(.green)
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    requestNotificationPermission()
                    scheduleDailyReminder()
                    fetchDailyMotivation()
                }
            }
            .navigationTitle("MoodCheck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Fonksiyonlar

    func getSuggestion(for mood: String) -> String {
        switch mood {
        case "😄": return "Harika! Bugün bir hedef koy 🎯"
        case "🙂": return "Kısa bir yürüyüş yapabilirsin 🚶‍♀️"
        case "😐": return "Odak müziği aç, 10 dk mola ver 🎧"
        case "😔": return "Nefes egzersizi yapmayı dene 🌬️"
        case "😢": return "Her şey yoluna girecek 💙"
        default: return "Kendine zaman ayır 💫"
        }
    }

    private func saveMoodToFirestore(_ mood: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayKey = dateFormatter.string(from: Date())
        let suggestion = getSuggestion(for: mood)

        let moodData: [String: Any] = [
            "mood": mood,
            "date": Timestamp(date: Date()),
            "suggestion": suggestion
        ]

        db.collection("users").document(uid)
            .collection("moodLogs").document(todayKey)
            .setData(moodData) { error in
                if error == nil {
                    saveStatus = "Bugünkü ruh halin kaydedildi ✅"
                }
            }
    }

    private func getAISuggestions() {
        isLoadingSuggestions = true
        aiSuggestions = []
        let prompt = """
        Kullanıcı şöyle yazdı: \(moodComment)
        Bu ruh haline göre kullanıcıya 5 kısa, uygulanabilir, motive edici öneri ver. Liste şeklinde, madde madde yaz:
        - ...
        """

        GeminiService.shared.generateText(from: prompt) { result in
            isLoadingSuggestions = false
            guard let result = result else {
                aiSuggestions = ["AI'dan öneri alınamadı."]
                return
            }
            aiSuggestions = result.components(separatedBy: "\n")
                .map { $0.replacingOccurrences(of: "•", with: "").replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
    }

    private func toggleTask(_ task: String) {
        if completedTasks.contains(task) {
            completedTasks.remove(task)
            points -= 10
        } else {
            completedTasks.insert(task)
            points += 10
            checkForBadges()
        }
    }

    private func checkForBadges() {
        if completedTasks.contains("Odak müziği aç") && !earnedBadges.contains("Odak Şampiyonu") {
            earnedBadges.append("Odak Şampiyonu")
        }

        if completedTasks.contains("Derin nefes egzersizi yap") && !earnedBadges.contains("Nefes Ustası") {
            earnedBadges.append("Nefes Ustası")
        }
    }

    private func addNewTask() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        userTasks.append(trimmed)
        newTaskText = ""
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "MoodCheck"
        content.body = "Bugünkü ruh halini kaydettin mi?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 10

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyMoodReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func fetchDailyMotivation() {
        let prompt = "Kullanıcının motivasyonunu artıracak tek paragraflık Türkçe bir mesaj yaz."
        GeminiService.shared.generateText(from: prompt) { result in
            if let result = result {
                motivationMessage = result
                showMotivation = true
            }
        }
    }
}
