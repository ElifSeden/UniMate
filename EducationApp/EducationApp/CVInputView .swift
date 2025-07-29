import SwiftUI
import PhotosUI
import PDFKit

struct CVInputView: View {
    // MARK: - Kişisel Bilgiler
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var linkedin = ""
    @State private var github = ""
    @State private var position = ""
    @State private var summary = "" // Yeni eklendi
    @State private var languagesText = "" // Yeni eklendi

    // MARK: - Fotoğraf
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?

    // MARK: - Eğitim & İş & Yetenekler
    @State private var educations: [EducationInfo] = [EducationInfo()]
    @State private var experiences: [ExperienceInfo] = [ExperienceInfo()]
    @State private var skillsText: String = ""

    // MARK: - Tema Seçimi
    @State private var selectedTheme: String = "Green"
    let themeOptions = ["Green", "Navy", "Maroon"]

    // MARK: - AI & PDF
    let geminiService = GeminiService()
    @State private var generatedCV: String?
    @State private var pdfData: Data?
    @State private var showPDFPreview = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Yeni Nesil CV Oluştur")
                        .font(.title)
                        .bold()

                    // Tema Seçimi
                    Text("Tema Rengi").font(.headline)
                    HStack(spacing: 20) {
                        themeCircle(color: UIColor.systemGreen, selected: selectedTheme == "Green")
                            .onTapGesture { selectedTheme = "Green" }
                        themeCircle(color: UIColor.systemBlue, selected: selectedTheme == "Navy")
                            .onTapGesture { selectedTheme = "Navy" }
                        themeCircle(color: UIColor.systemRed, selected: selectedTheme == "Maroon")
                            .onTapGesture { selectedTheme = "Maroon" }
                    }

                    // Fotoğraf
                    HStack {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .overlay(Text("Foto").font(.caption))
                        }

                        PhotosPicker("Profil Fotoğrafı Yükle", selection: $selectedPhoto, matching: .images)
                            .onChange(of: selectedPhoto) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        profileImage = uiImage
                                    }
                                }
                            }
                    }

                    // Bilgiler
                    labeledTextField(title: "Full Name", text: $name)
                    labeledTextField(title: "Position / Title", text: $position)
                    labeledTextField(title: "Email", text: $email, keyboard: .emailAddress)
                    labeledTextField(title: "Phone", text: $phone)
                    labeledTextField(title: "LinkedIn", text: $linkedin)
                    labeledTextField(title: "GitHub", text: $github)

                    // Tanıtım
                    Text("Kısa Tanıtım Yazısı").font(.headline)
                    TextEditor(text: $summary)
                        .frame(height: 100)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Eğitim
                    Text("Eğitim Bilgileri").font(.headline)
                    ForEach(educations.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            labeledTextField(title: "School", text: $educations[index].school)
                            labeledTextField(title: "Degree", text: $educations[index].degree)
                            DatePicker("Start Date", selection: $educations[index].startDate, displayedComponents: .date)
                            DatePicker("End Date", selection: $educations[index].endDate, displayedComponents: .date)
                        }
                    }
                    Button("+ Add Education") {
                        educations.append(EducationInfo())
                    }

                    // Deneyim
                    Text("Work Experience").font(.headline)
                    ForEach(experiences.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            labeledTextField(title: "Position", text: $experiences[index].position)
                            labeledTextField(title: "Company", text: $experiences[index].company)
                            labeledTextField(title: "Description", text: $experiences[index].description)
                            DatePicker("Start Date", selection: $experiences[index].startDate, displayedComponents: .date)
                            DatePicker("End Date", selection: $experiences[index].endDate, displayedComponents: .date)
                        }
                    }
                    Button("+ Add Experience") {
                        experiences.append(ExperienceInfo())
                    }

                    // Yetenek
                    Text("Skills (virgülle ayırın)").font(.headline)
                    labeledTextField(title: "Swift, Firebase, Teamwork", text: $skillsText)

                    // Diller
                    Text("Languages (virgülle ayırın)").font(.headline)
                    labeledTextField(title: "English - Native, Turkish - Fluent", text: $languagesText)

                    // CV Oluştur
                    Button(action: {
                        let skillsArray = skillsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        let languages = languagesText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                        let theme: PDFCreator.Theme = {
                            switch selectedTheme {
                                case "Navy": return .navy
                                case "Maroon": return .maroon
                                default: return .green
                            }
                        }()

                        pdfData = PDFCreator.createStyledPDF(
                            name: name,
                            position: position,
                            email: email,
                            phone: phone,
                            linkedin: linkedin,
                            github: github,
                            skills: skillsArray,
                            experiences: experiences,
                            educations: educations,
                            profileImage: profileImage,
                            summary: summary,
                            languages: languages,
                            theme: theme
                        )

                        showPDFPreview = true
                    }) {
                        Text("Generate My CV")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Önizleme
                    if let result = generatedCV {
                        Text("\u{1F4C4} AI Generated CV:")
                            .font(.headline)
                        Text(result)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("CV Mentor")
            .sheet(isPresented: $showPDFPreview) {
                if let data = pdfData {
                    PDFPreviewView(pdfData: data)
                }
            }
        }
    }

    // MARK: - Yardımcı Görünümler
    func labeledTextField(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("", text: text)
                .keyboardType(keyboard)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }

    func themeCircle(color: UIColor, selected: Bool) -> some View {
        Circle()
            .strokeBorder(selected ? Color.black : Color.clear, lineWidth: 3)
            .background(Circle().fill(Color(color)))
            .frame(width: 32, height: 32)
    }
}
struct EducationInfo: Identifiable {
    let id = UUID()
    var school: String = ""
    var degree: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
}

struct ExperienceInfo: Identifiable {
    let id = UUID()
    var position: String = ""
    var company: String = ""
    var description: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
}
