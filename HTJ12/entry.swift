import SwiftUI
import AVFoundation
import AVKit

class CameraModel: NSObject, ObservableObject {
    private var captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    @Published var isRecording = false
    @Published var recordedURL: URL?

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: device) else { return }

        if captureSession.canAddInput(videoInput) { captureSession.addInput(videoInput) }

        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }

        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill

        captureSession.startRunning()
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }

    func startRecording() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tempName = "recording_\(UUID().uuidString).mov"
        let tempURL = documentsDirectory.appendingPathComponent(tempName)
        
        if FileManager.default.fileExists(atPath: tempURL.path) {
            do {
                try FileManager.default.removeItem(at: tempURL)
            } catch {
                print("Failed to remove existing temp file: \(error)")
                return
            }
        }
        
        print("Starting recording to: \(tempURL.path)")
        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
    }

    func stopRecording() {
        videoOutput.stopRecording()
        isRecording = false
    }
}

extension CameraModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            if FileManager.default.fileExists(atPath: outputFileURL.path) {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: Date())
                let finalURL = documentsDirectory.appendingPathComponent("\(dateString).mov")
                if FileManager.default.fileExists(atPath: finalURL.path) {
                    try? FileManager.default.removeItem(at: finalURL)
                }
                do {
                    try FileManager.default.copyItem(at: outputFileURL, to: finalURL)
                    DispatchQueue.main.async {
                        self.recordedURL = finalURL
                        print("Recording finished, saved at: \(finalURL.path)")
                    }
                } catch {
                    print("Failed to save recording: \(error.localizedDescription)")
                }
            } else {
                print("Recording finished but file does not exist at: \(outputFileURL.path)")
            }
        } else {
            print("Recording error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let cameraModel: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        if let previewLayer = cameraModel.getPreviewLayer() {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CameraWatcherView: View {
    @StateObject private var cameraModel = CameraModel()
    @State private var navigateToPlayback = false
    @State private var recordingTime: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            CameraPreview(cameraModel: cameraModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if cameraModel.isRecording {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text("Recording: \(formattedTime(recordingTime))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .onReceive(timer) { _ in
                        recordingTime += 1
                    }
                }

                Spacer()

                Button(action: {
                    if cameraModel.isRecording {
                        cameraModel.stopRecording()
                        recordingTime = 0
                    } else {
                        cameraModel.startRecording()
                    }
                }) {
                    Circle()
                        .fill(cameraModel.isRecording ? Color.red : Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding()
                }
            }
        }
        .onReceive(cameraModel.$recordedURL) { url in
            if url != nil {
                navigateToPlayback = true
            }
        }
        .fullScreenCover(isPresented: $navigateToPlayback) {
            if let recordedURL = cameraModel.recordedURL {
                VideoPlaybackView(videoURL: recordedURL)
            }
        }
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Video Playback View
struct VideoPlaybackView: View {
    var videoURL: URL
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .frame(height: UIScreen.main.bounds.height * 0.8)
            Spacer()
            // Only a dismiss button now.
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Dismiss")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
