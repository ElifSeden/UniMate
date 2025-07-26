import SwiftUI

struct HomeView: View {
    @State private var points: Int = 300
    @State private var selectedDate = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["P", "S", "Ç", "P", "C", "C", "P"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Hi Elif,")
                                .font(.title)
                                .bold()
                            (
                                Text("You have ")
                                    .font(.subheadline)
                                +
                                Text("4 pending tests")
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                +
                                Text(" this week")
                            )
                        }
                        Spacer()
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.gray)
                    }

                    // MARK: - New Calendar Style Day Picker
                    HStack(spacing: 12) {
                        ForEach(0..<7) { offset in
                            let day = Calendar.current.date(byAdding: .day, value: offset - currentWeekdayIndex(), to: Date())!
                            let isToday = calendar.isDateInToday(day)
                            let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)

                            VStack(spacing: 4) {
                                Text(weekdays[offset])
                                    .font(.caption)
                                    .foregroundColor(.black)

                                Text("\(calendar.component(.day, from: day))")
                                    .font(.subheadline)
                                    .fontWeight(isToday ? .bold : .regular)
                                    .foregroundColor(isToday ? .black : .gray)
                                    .frame(width: 32, height: 32)
                                    .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                            }
                            .onTapGesture {
                                selectedDate = day
                            }
                        }
                    }

                    // MARK: - Points Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 120)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(points) Points")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)

                                Text("Cross 500 this week to get a free 1-on-1 class")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button("Take test now") {
                                // Test action
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        .padding()
                    }

                    // MARK: - Pending Tests
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("4 Pending tests")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "info.circle")
                        }

                        ForEach(testData, id: \.id) { test in
                            TestCard(test: test)
                        }
                    }

                    // MARK: - Subjects
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subjects")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(subjects, id: \.self) { subject in
                                Text(subject)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(colors: [.purple, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }

    // Bugünkü gün index'ini hesaplar (0-6)
    private func currentWeekdayIndex() -> Int {
        let weekday = calendar.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }
}

struct TestCard: View {
    var test: TestModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(test.title)
                    .bold()
                Text(test.subject)
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            Spacer()
            Text(test.timeRemaining)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct TestModel {
    let id = UUID()
    let title: String
    let subject: String
    let timeRemaining: String
}

let testData = [
    TestModel(title: "Law of Motion", subject: "Physics", timeRemaining: "1d:10Hr"),
    TestModel(title: "Law of Motion", subject: "Chemistry", timeRemaining: "1d:10Hr"),
    TestModel(title: "Law of Motion", subject: "Maths", timeRemaining: "1d:10Hr"),
    TestModel(title: "Law of Motion", subject: "Physics", timeRemaining: "1d:10Hr")
]

let subjects = ["Mathematics", "Chemistry", "Physics", "Reasoning"]
