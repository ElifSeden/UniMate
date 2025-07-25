import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // Üst Bilgi
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi Elif,")
                        .font(.title2)
                        .bold()
                    
                    Text("You have 4 pending tests this week")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "bell")
                    .font(.title3)
                    .padding(.trailing, 4)
                
                Image("profile")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            .padding(.horizontal)

            // Puan Kartı
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .frame(height: 100)
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Points")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("120")
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                    }
                    .padding()
                )
                .padding(.horizontal)

            // Pending Tests Kartı
            VStack(alignment: .leading, spacing: 8) {
                Text("Pending Tests")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        TestCard(title: "Math", date: "Jul 28", progress: 0.7)
                        TestCard(title: "Physics", date: "Jul 30", progress: 0.3)
                        TestCard(title: "History", date: "Aug 1", progress: 0.5)
                    }
                    .padding(.horizontal)
                }
            }

            // Subject Buttons
            VStack(alignment: .leading, spacing: 8) {
                Text("Subjects")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        SubjectButton(title: "Math", icon: "function", color: .purple)
                        SubjectButton(title: "Biology", icon: "leaf", color: .green)
                        SubjectButton(title: "History", icon: "book", color: .orange)
                        SubjectButton(title: "Chemistry", icon: "flask", color: .blue)
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()
            
            // Bottom Nav Bar
            HStack {
                Spacer()
                Image(systemName: "house.fill").foregroundColor(.blue)
                Spacer()
                Image(systemName: "calendar")
                Spacer()
                Image(systemName: "brain.head.profile")
                Spacer()
                Image(systemName: "person.crop.circle")
                Spacer()
            }
            .font(.title2)
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .padding(.top)
    }
}

// Test Kartı
struct TestCard: View {
    var title: String
    var date: String
    var progress: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text("Due: \(date)")
                .font(.caption)
                .foregroundColor(.gray)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
        .frame(width: 160)
    }
}

// Konu Butonu
struct SubjectButton: View {
    var title: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
        }
        .frame(width: 120, height: 100)
        .background(color)
        .cornerRadius(16)
    }
}

#Preview {
    HomeView()
}
