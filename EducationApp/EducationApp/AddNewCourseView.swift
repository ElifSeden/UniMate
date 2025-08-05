import SwiftUI

struct AddNewCourseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var selectedDay = "Pazartesi"
    @State private var selectedHour = 9

    var onSave: (Course) -> Void

    let days = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    let hours = Array(7...18)

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
             
                HStack {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    Spacer()
                }

                Text("Ders Ekle")
                    .font(.largeTitle)
                    .bold()

                Text("Ders Bilgileri")
                    .font(.headline)
                    .foregroundColor(.gray)

                VStack(spacing: 15) {
                 
                    TextField("Ders/Konu", text: $name)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                   
                    Menu {
                        ForEach(days, id: \.self) { day in
                            Button(action: {
                                selectedDay = day
                            }) {
                                Text(day)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gün")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(selectedDay)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }

                    Menu {
                        ForEach(hours, id: \.self) { hour in
                            Button(action: {
                                selectedHour = hour
                            }) {
                                Text("\(hour):00")
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Saat")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(selectedHour):00")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }

                   
                    TextField("Yer (isteğe bağlı)", text: $location)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                   
                    Button(action: {
                        let newCourse = Course(
                            name: name,
                            day: selectedDay,
                            hour: selectedHour,
                            location: location,
                            color: Color.random()
                        )
                        onSave(newCourse)
                        dismiss()
                    }) {
                        Text("Dersi Kaydet")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.white)
        }
    }
}
