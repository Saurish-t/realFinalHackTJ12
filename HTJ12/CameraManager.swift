//
//  cameraManager.swift
//  hacktj12
//
//  Created by Saurish Tripathi on 3/8/25.
//

//
//  CameraManager.swift
//  HackTJ 12.0
//
//  Created by Gautam Annamalai on 3/8/25.
//

import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var currentVideoDevice: AVCaptureDevice?
    private var currentPosition: AVCaptureDevice.Position = .back
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.beginConfiguration()
        configureCamera(position: currentPosition)
        session.commitConfiguration()
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        self.previewLayer = preview
    }
    
    private func configureCamera(position: AVCaptureDevice.Position) {
        session.inputs.forEach { session.removeInput($0) }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            print("Failed to set up camera input")
            return
        }
        
        session.addInput(videoInput)
        currentVideoDevice = videoDevice
        currentPosition = position
        
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
    }
    
    func startSession() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.sessionQueue.async {
                        self.session.startRunning()
                    }
                }
            } else {
                print("Camera access denied")
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func startRecording() {
        let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("recording.mov")
        movieOutput.startRecording(to: outputPath, recordingDelegate: self)
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        movieOutput.stopRecording()
        self.recordingCompletion = completion
    }
    
    func switchCamera() {
        session.beginConfiguration()
        let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        configureCamera(position: newPosition)
        session.commitConfiguration()
    }
    
    private var recordingCompletion: ((URL?) -> Void)?
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording failed: \(error.localizedDescription)")
            recordingCompletion?(nil)
        } else {
            print("Recording saved to: \(outputFileURL)")
            recordingCompletion?(outputFileURL)
        }
        recordingCompletion = nil
    }
}
