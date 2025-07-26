import SwiftUI

struct GeminiScreen: View {
    @State private var prompt: String = ""
    @State private var response: String = ""
    @State private var isLoading = false


    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ask Gemini")
                    .font(.largeTitle)
                    .bold()

                TextField("Enter your question...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                
                 
                    Text("Ask")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(prompt.isEmpty)

                if isLoading {
                    ProgressView()
                        .padding()
                }

                ScrollView {
                    Text(response)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Gemini AI")
        }
    }

