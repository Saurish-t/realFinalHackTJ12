import SwiftUI
import AVKit
import AVFoundation

extension AVFileType {
    static let wav = AVFileType("com.microsoft.waveform-audio")
}

struct CalendarProgressView: View {
    @State private var selectedDate: Date = Date()
    @State private var isExpanded: Bool = false
    @State private var videoURL: URL?
    @State private var shouldNavigateToVideo: Bool = false
    @State private var videoDescription: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Updated background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header styling
                    Text("Progress")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    
                    // DatePicker styled as a card
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .onChange(of: selectedDate) { _ in
                            withAnimation {
                                isExpanded = true
                            }
                            loadVideoForDate()
                        }
                    
                    // Buttons always visible but disabled if no videoURL available
                    HStack(spacing: 12) {
                        NavigationLink(
                            destination: VideoPlayerView(videoURL: videoURL ?? URL(fileURLWithPath: "")),
                            isActive: $shouldNavigateToVideo
                        ) {
                            Button(action: {
                                shouldNavigateToVideo = true
                            }) {
                                Label("View Video", systemImage: "play.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(videoURL == nil)
                        
                        Button(action: {
                            if let videoURL = videoURL {
                                sendVideoToDescriptionServer(videoURL: videoURL)
                            }
                        }) {
                            Label("Describe Video", systemImage: "text.bubble")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(videoURL == nil)
                    }
                    .padding(.horizontal)
                    
                    // Description card with ScrollView for tight and scrollable layout
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Date: \(selectedDate.formatted(date: .long, time: .omitted))")
                                .font(.headline)
                            ScrollView {
                                Text(!videoDescription.isEmpty ? videoDescription : "Awaiting video description...")
                                    .font(.body)
                                    .padding(4)
                            }
                            .frame(maxHeight: 150)
                        }
                        .padding()
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    func loadVideoForDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let videoName = "\(dateFormatter.string(from: selectedDate)).mov"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoPath = documentsDirectory.appendingPathComponent(videoName)
        
        print("Looking for video at: \(videoPath.path)")
        
        if FileManager.default.fileExists(atPath: videoPath.path) {
            videoURL = videoPath
            print("Loading video for date: \(selectedDate)")
        } else {
            videoURL = nil
            print("No video found for date: \(selectedDate)")
        }
    }
    
    // New function: process the video to extract audio and send to server
    func processVideoAudio() {
        guard let movURL = videoURL else { return }
        convertMovToWav(inputURL: movURL) { wavURL in
            guard let wavURL = wavURL else {
                print("Audio conversion failed")
                return
            }
            sendWavToServer(wavURL: wavURL)
        }
    }
    
    // New function: convert MOV to WAV (conversion code may need further tuning)
    func convertMovToWav(inputURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: inputURL)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let wavURL = documentsDirectory.appendingPathComponent("convertedAudio.wav")
        try? FileManager.default.removeItem(at: wavURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            completion(nil)
            return
        }
        exportSession.outputURL = wavURL
        exportSession.outputFileType = .wav
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                print("Conversion successful: \(wavURL)")
                completion(wavURL)
            } else {
                print("Conversion failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    // New function: send WAV file to the Flask server endpoint
    func sendWavToServer(wavURL: URL) {
        let serverURL = URL(string: "http://127.0.0.1:5010/predict")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        // Create a multipart/form-data body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        // Append file data
        if let fileData = try? Data(contentsOf: wavURL) {
            let filename = wavURL.lastPathComponent
            let mimetype = "audio/wav"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        request.timeoutInterval = 300
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending WAV: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No response data received")
                return
            }
            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let emotion = result["emotion"] {
                        print("Predicted Emotion: \(emotion)")
                    } else if let errorMsg = result["error"] {
                        print("Error: \(errorMsg)")
                    } else {
                        print("Unexpected response: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                }
            } catch {
                print("Failed to parse JSON: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }
        print("Sending \(wavURL.path) to \(serverURL)...")
        task.resume()
    }
    
    // New function: send video to Flask describe_video endpoint
    func sendVideoToDescriptionServer(videoURL: URL) {
        guard let videoData = try? Data(contentsOf: videoURL) else {
            print("Could not read video data.")
            return
        }
        // Update "192.168.x.x" with your server's Wi-Fi IP address.
        let serverURL = URL(string: "http://10.180.8.173:5020/describe_video")!
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = videoURL.lastPathComponent
        let mimetype = "video/mp4" // adjust if necessary
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(videoData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        request.timeoutInterval = 300
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending video: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No response data received")
                return
            }
            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let description = result["description"] as? String {
                    DispatchQueue.main.async {
                        self.videoDescription = description
                    }
                    print("Video Description:")
                    print(description)
                } else if let errorMsg = (try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])?["error"] as? String {
                    print("Error: \(errorMsg)")
                } else {
                    print("Unexpected response: \(String(data: data, encoding: .utf8) ?? "")")
                }
            } catch {
                print("Failed to parse JSON response.")
            }
        }
        print("Sending \(videoURL.path) to \(serverURL)...")
        task.resume()
    }
}

struct VideoPlayerView: View {
    var videoURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarTitle("Video Playback", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        )
    }
}

struct ExpandedDateView: View {
    var date: Date
    
    var body: some View {
        VStack {
            Text("Selected Date: \(date.formatted(date: .long, time: .omitted))")
                .font(.title2)
                .padding()
                .background(Color.cyan.opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 20)
            
            Text("Details for the selected date go here.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    CalendarProgressView()
}
