import SwiftUI

struct TimetableView: View {
    @State private var courses: [Course] = sampleCourses
    @State private var showingAddCourse = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Schedule")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Your weekly courses")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    showingAddCourse = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            GridTimetableView(courses: $courses)

                .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $showingAddCourse) {
            AddNewCourseView { newCourse in
                courses.append(newCourse)
            }
        }
    }
}
