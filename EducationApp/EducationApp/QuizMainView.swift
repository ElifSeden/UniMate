import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct QuizMainView: View {
    @State private var selectedDocumentURL: URL?
    @State private var showPicker = false
    @State private var showSetup = false
    @State private var isLoading = false
    @State private var generatedQuestions: [QuizQuestion] = []
    @State private var navigateToQuiz = false

    private let quizService = QuizService()

    var body: some View {
        NavigationView {
            VStack {
                // Başlık barı
                HStack {
                    Image(systemName: "checklist")
                        .foregroundColor(.white)
                    Text("Quiz")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)

                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.6))

                    if let url = selectedDocumentURL {
                        Text(url.lastPathComponent)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if isLoading {
                            ProgressView("Hazırlanıyor...")
                                .padding()
                        } else {
                            Button("Devam Et") {
                                showSetup = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                        }

                    } else {
                        Text("PDF'e göre AI destekli quiz oluşturmak için dosya yükleyin.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        Button("PDF Seç") {
                            showPicker = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()

                NavigationLink(destination: QuizQuestionView(questions: generatedQuestions),
                               isActive: $navigateToQuiz) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    if let url = url {
                        self.selectedDocumentURL = url
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                PDFQuizSetupView { type, count in
                    guard let url = selectedDocumentURL,
                          let pdfDocument = PDFDocument(url: url),
                          let text = pdfDocument.string else {
                        return
                    }

                    isLoading = true
                    quizService.generateQuiz(from: text, type: type, count: count) { questions in
                        DispatchQueue.main.async {
                            self.generatedQuestions = questions
                            self.isLoading = false
                            self.navigateToQuiz = true
                        }
                    }
                }
            }
        }
    }
}
