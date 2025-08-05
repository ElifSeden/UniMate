import SwiftUI

struct GeminiScreen: View {
    @State private var prompt: String = ""
    @State private var response: String = ""
    @State private var isChatOpen = false
    @State private var isLoading = false

    let sampleQuestions = [
        "Proje konum ne olabilir?",
        "CV’me neler yazmalıyım?",
        "Verimli ders çalışma yolları?",
        "Staj nereden bulabilirim?",
        "Yurtdışı master hakkında bilgi verir misin?",
        "Ders çalışırken nasıl odaklanırım?",
        "Yazın kendimi nasıl geliştiririm?",
        "Motivasyonumu nasıl artırabilirim?",
        "Zaman yönetimini nasıl geliştirebilirim?",
        "Finale nasıl çalışmalıyım?"
    ]

    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                  
                    ZStack(alignment: .bottom) {
                        Color.blue
                            .edgesIgnoringSafeArea(.top)

                        Text("Üniversite Öğrencileri En Çok Ne Soruyor?")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                    }
                    .frame(height: 80)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sampleQuestions, id: \.self) { question in
                                Button(action: {
                                    prompt = question
                                    isChatOpen = true
                                }) {
                                    Text(question)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .padding(.top, 8)
                    }

                    Spacer()
                }
                .navigationBarHidden(true)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isChatOpen.toggle()
                    }) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
            
            if isChatOpen {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Gemini Chat")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    isChatOpen = false
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                }
                            }

                            TextField("Sorunu yaz...", text: $prompt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button("Sor") {
                                askGemini()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(prompt.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(prompt.isEmpty)

                            if isLoading {
                                ProgressView("Yanıtlanıyor...")
                            }

                            if !response.isEmpty {
                                Text("Yanıt:")
                                    .font(.subheadline).bold()
                                ScrollView {
                                    Text(response)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .frame(height: 150)
                            }
                        }
                        .padding()
                        .frame(width: 320)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
                .transition(.move(edge: .trailing))
                .animation(.easeInOut, value: isChatOpen)
            }
        }
    }

    func askGemini() {
        isLoading = true
        GeminiService().generateText(from: prompt) { result in
            DispatchQueue.main.async {
                self.response = result ?? "Yanıt alınamadı."
                self.isLoading = false
            }
        }
    }
}
