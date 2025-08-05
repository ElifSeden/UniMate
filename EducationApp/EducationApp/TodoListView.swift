import SwiftUI

struct TodoListView: View {
    @Environment(\.dismiss) var dismiss

    @State private var tasks: [String] = []
    @State private var newTask: String = ""
    @State private var completedTasks: Set<String> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                VStack(alignment: .center, spacing: 4) {
                    Text("Görevlerim")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Günlük görevlerini takip et ve tamamla.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(20)
                .padding(.horizontal)

                HStack {
                    TextField("Yeni görev ekle...", text: $newTask)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .disabled(newTask.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                if tasks.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Henüz görev eklenmedi")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(tasks, id: \.self) { task in
                                HStack {
                                    Text(task)
                                        .font(.body)
                                        .foregroundColor(completedTasks.contains(task) ? .gray : .primary)
                                        .strikethrough(completedTasks.contains(task))

                                    Spacer()

                                    Button {
                                        completedTasks.insert(task)
                                    } label: {
                                        Image(systemName: completedTasks.contains(task) ? "checkmark.seal.fill" : "circle")
                                            .foregroundColor(completedTasks.contains(task) ? .green : .gray)
                                            .font(.system(size: 24))
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                }

                Spacer()
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }

    func addTask() {
        let trimmed = newTask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(trimmed)
        newTask = ""
    }
}
