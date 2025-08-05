import SwiftUI
import PhotosUI
import PDFKit

struct PDFWrapper: Identifiable {
    let id = UUID()
    let data: Data
}

struct CVInputView: View {
    
    @State private var name = ""
    @State private var position = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var location = ""
    @State private var website = ""
    @State private var linkedin = ""
    @State private var github = ""
    @State private var summary = ""
    @State private var skillsText = ""
    @State private var languagesText = ""

    
    @State private var educations: [EducationInfo] = [EducationInfo()]
    @State private var experiences: [ExperienceInfo] = [ExperienceInfo()]

   
    @State private var selectedTheme: String = "Green"
    let themeOptions = ["Green", "Navy", "Maroon", "Black", "DarkYellow"]

   
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?


    @State private var pdfWrapper: PDFWrapper?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
               
                ZStack(alignment: .bottom) {
                    Color.blue
                        .ignoresSafeArea(edges: .top)
                    HStack {
                        Spacer()
                        Text("CV Mentor")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.bottom, 12)
                }
                .frame(height: 80)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CV Tema Rengi").font(.headline)
                            HStack(spacing: 16) {
                                themeCircle(color: .systemGreen, selected: selectedTheme == "Green")
                                    .onTapGesture { selectedTheme = "Green" }
                                themeCircle(color: .systemBlue, selected: selectedTheme == "Navy")
                                    .onTapGesture { selectedTheme = "Navy" }
                                themeCircle(color: .systemRed, selected: selectedTheme == "Maroon")
                                    .onTapGesture { selectedTheme = "Maroon" }
                                themeCircle(color: .black, selected: selectedTheme == "Black")
                                    .onTapGesture { selectedTheme = "Black" }
                                themeCircle(color: UIColor(red: 0.75, green: 0.6, blue: 0.0, alpha: 1.0), selected: selectedTheme == "DarkYellow")
                                    .onTapGesture { selectedTheme = "DarkYellow" }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)

                       
                        HStack {
                            if let img = profileImage {
                                Image(uiImage: img)
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
                        .padding(.horizontal)

                    
                        Group {
                            labeledTextField(title: "Ad Soyad", text: $name)
                            labeledTextField(title: "Pozisyon / Unvan", text: $position)
                            labeledTextField(title: "E-posta", text: $email, keyboard: .emailAddress)
                            labeledTextField(title: "Telefon", text: $phone)
                            labeledTextField(title: "Konum", text: $location)
                            labeledTextField(title: "Web Sitesi", text: $website)
                            labeledTextField(title: "LinkedIn", text: $linkedin)
                            labeledTextField(title: "GitHub", text: $github)

                            Text("Kısa Tanıtım Yazısı").font(.headline)
                            TextEditor(text: $summary)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Eğitim Bilgileri").font(.headline)
                            ForEach(educations.indices, id: \..self) { i in
                                VStack(alignment: .leading, spacing: 6) {
                                    labeledTextField(title: "Okul", text: $educations[i].school)
                                    labeledTextField(title: "Bölüm / Derece", text: $educations[i].degree)
                                    DatePicker("Başlangıç", selection: $educations[i].startDate, displayedComponents: .date)
                                    DatePicker("Bitiş", selection: $educations[i].endDate, displayedComponents: .date)
                                }
                                .padding(.vertical, 4)
                            }
                            Button("+ Eğitim Ekle") { educations.append(EducationInfo()) }
                        }
                        .padding(.horizontal)

               
                        VStack(alignment: .leading, spacing: 10) {
                            Text("İş Deneyimi").font(.headline)
                            ForEach(experiences.indices, id: \..self) { i in
                                VStack(alignment: .leading, spacing: 6) {
                                    labeledTextField(title: "Pozisyon", text: $experiences[i].position)
                                    labeledTextField(title: "Şirket", text: $experiences[i].company)
                                    labeledTextField(title: "Açıklama", text: $experiences[i].description)
                                    DatePicker("Başlangıç", selection: $experiences[i].startDate, displayedComponents: .date)
                                    DatePicker("Bitiş", selection: $experiences[i].endDate, displayedComponents: .date)
                                }
                                .padding(.vertical, 4)
                            }
                            Button("+ Deneyim Ekle") { experiences.append(ExperienceInfo()) }
                        }
                        .padding(.horizontal)

                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Yetenekler (virgülle ayırın)").font(.headline)
                            labeledTextField(title: "Örnek: Swift, Firebase, Teamwork", text: $skillsText)
                            Text("Yabancı Diller (virgülle ayırın)").font(.headline)
                            labeledTextField(title: "Örnek: English - Native, Turkish - Fluent", text: $languagesText)
                        }
                        .padding(.horizontal)

                       
                        Button {
                            let skills = skillsText
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            let langs = languagesText
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            let theme: PDFCreator.Theme = {
                                switch selectedTheme {
                                case "Navy": return .navy
                                case "Maroon": return .maroon
                                case "Black": return .black
                                case "DarkYellow": return .darkYellow
                                default: return .green
                                }
                            }()

                            DispatchQueue.global(qos: .userInitiated).async {
                                let data = PDFCreator.createStyledPDF(
                                    name: name,
                                    position: position,
                                    email: email,
                                    phone: phone,
                                    location: location,
                                    linkedin: linkedin,
                                    github: github,
                                    website: website,
                                    skills: skills,
                                    experiences: experiences,
                                    educations: educations,
                                    profileImage: profileImage,
                                    summary: summary,
                                    languages: langs,
                                    theme: theme
                                )
                                DispatchQueue.main.async {
                                    self.pdfWrapper = PDFWrapper(data: data)
                                }
                            }
                        } label: {
                            Text("CV'mi Oluştur")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(item: $pdfWrapper) { wrapper in
                DownloadablePDFView(pdfData: wrapper.data)
            }
        }
    }


    private func labeledTextField(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).foregroundColor(.gray)
            TextField("", text: text)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }

    private func themeCircle(color: UIColor, selected: Bool) -> some View {
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
