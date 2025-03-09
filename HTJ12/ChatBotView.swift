import SwiftUI
import OpenAI

struct ChatbotView2: View {
    @State private var userInput: String = ""
    @State private var messages: [(sender: String, content: String)] = []
    @State private var isLoading: Bool = false
    @FocusState private var isInputFocused: Bool
    
    private let apiKey = "sk-proj-aVYLU8m6MsMhwyQNbZxGT3BlbkFJG6fhOybvRgPCuxca568O"
    
    var body: some View {
        ZStack {
            Color(red: 0.6, green: 0.85, blue: 0.9).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Talk to TheraAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<messages.count, id: \.self) { index in
                            let message = messages[index]
                            HStack {
                                if message.sender == "You" {
                                    Spacer()
                                    Text("\(message.content)")
                                        .padding(10)
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                                } else {
                                    Text("\(message.content)")
                                        .padding(10)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if isLoading {
                            HStack {
                                Text("xrAI is typing...")
                                    .italic()
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            isInputFocused = false
                        }
                )
                
                HStack {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        
                        if userInput.isEmpty {
                            Text("Type your message")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 15)
                        }
                        
                        TextField("", text: $userInput, axis: .vertical)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .foregroundColor(.black)
                            .background(Color.clear)
                            .disabled(isLoading)
                            .focused($isInputFocused)
                    }
                    .frame(height: 60)
                    .padding(.horizontal)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .padding()
                            .background(userInput.isEmpty || isLoading ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .offset(x: -5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 17)
                                    .stroke(Color.white, lineWidth: 2)
                                    .offset(x: -5)
                            )
                    }
                    .padding(.trailing)
                    .disabled(userInput.isEmpty || isLoading)
                }
                
                Button(action: {
                    isInputFocused = false
                }) {
                    HStack {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Dismiss Keyboard")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                }
                .opacity(isInputFocused ? 1 : 0)
                .animation(.easeInOut, value: isInputFocused)
                .padding(.bottom, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty && !isLoading else { return }
        
        let userMessage = userInput
        messages.append((sender: "You", content: userMessage))
        userInput = ""
        isInputFocused = false
        
        isLoading = true
        
        fetchBotResponse(for: userMessage)
    }
    
    private func fetchBotResponse(for message: String) {
        let openAI = OpenAI(apiToken: apiKey)
        
        Task {
            do {
                // Using a simple string API call approach
                let jsonBody: [String: Any] = [
                    "model": "gpt-3.5-turbo",
                    "messages": [
                        ["role": "system", "content": "You are xrAI, a helpful AI assistant."],
                        ["role": "user", "content": message]
                    ],
                    "max_tokens": 1000
                ]
                
                // Convert to JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
                
                // Create URL request
                var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
                request.httpMethod = "POST"
                request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                // Make the request
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Handle the response
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    DispatchQueue.main.async {
                        self.messages.append((sender: "xrAI", content: content))
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.messages.append((sender: "xrAI", content: "Sorry, I couldn't generate a response."))
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.messages.append((sender: "xrAI", content: "Error: \(error.localizedDescription)"))
                    self.isLoading = false
                }
            }
        }
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView2()
    }
}
