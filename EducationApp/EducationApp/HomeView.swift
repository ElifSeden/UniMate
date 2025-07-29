import SwiftUI

struct HomeView: View {
    @State private var points: Int = 300
    @State private var selectedDate = Date()
    @State private var exams: [Exam] = []
    @State private var showingAddExam = false
    @State private var showingTimetable = false
    @State private var courses: [Course] = sampleCourses
    @State private var weekOffset: Int = 0

    // Weekday labels - Sunday to Saturday
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    // Use system calendar with default (Sunday-starting)
    private let calendar = Calendar.current

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

                    // MARK: - Week Switchable Calendar
                    let currentWeekStart = calendar.date(byAdding: .day, value: weekOffset * 7, to: Date())!

                    HStack {
                        Button(action: {
                            withAnimation {
                                weekOffset -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }

                        Spacer()

                        ForEach(getWeekDates(for: currentWeekStart), id: \.self) { day in
                            let isToday = calendar.isDateInToday(day)
                            let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)

                            VStack(spacing: 4) {
                                // Map .weekday (1=Sun, ..., 7=Sat) to index 0-6
                                Text(weekdays[calendar.component(.weekday, from: day) - 1])
                                    .font(.caption)
                                    .foregroundColor(.black)

                                Text("\(calendar.component(.day, from: day))")
                                    .font(.subheadline)
                                    .fontWeight(isToday ? .bold : .regular)
                                    .foregroundColor(isToday ? .black : .gray)
                                    .frame(width: 32, height: 32)
                                    .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
                                    .clipShape(Circle())
                            }
                            .onTapGesture {
                                selectedDate = day
                            }
                        }

                        Spacer()

                        Button(action: {
                            withAnimation {
                                weekOffset += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Exams on Selected Date
                    let filteredExams = exams.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }

                    if !filteredExams.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exams on this day")
                                .font(.headline)

                            ForEach(filteredExams) { exam in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exam.subject)
                                        .bold()
                                    if !exam.note.isEmpty {
                                        Text(exam.note)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                    }

                    // MARK: - Add Exam Button
                    Button(action: {
                        showingAddExam = true
                    }) {
                        Label("Add Exam", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
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
                                // Action
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        .padding()
                    }

                    // MARK: - Timetable Card
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
                        .padding(.horizontal, 4)

                        GridTimetableView(courses: courses)
                            .padding(.horizontal, 4)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddExam) {
                AddExamView { newExam in
                    exams.append(newExam)
                }
            }
            .sheet(isPresented: $showingTimetable) {
                AddNewCourseView { newCourse in
                    courses.append(newCourse)
                }
            }
        }
    }

    // MARK: - Week Helpers
    private func getWeekDates(for baseDate: Date) -> [Date] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        let weekInterval = cal.dateInterval(of: .weekOfYear, for: baseDate)!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }
}

// MARK: - Exam Model
struct Exam: Identifiable {
    let id = UUID()
    let subject: String
    let date: Date
    let note: String
}
