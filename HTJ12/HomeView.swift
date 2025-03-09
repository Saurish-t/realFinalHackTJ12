import SwiftUI
import AVFoundation
import Vision
import UIKit

struct HomeView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("hasSetFontPreferences") private var hasSetFontPreferences: Bool = false
    @AppStorage("selectedFont") private var selectedFont: String = "Arial"
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 20
    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CameraWatcherView()
                .tabItem {
                    Label("Text to Speech", systemImage: "waveform")
                }
            
            //VisionView()
                .tabItem {
                    Label("Adaptive Reading", systemImage: "eye.fill")
                }
        }
        .accentColor(.white)
    }
}

struct MainView: View {
    @State private var showSettings = false
    @State private var showAdaptiveTutorial = false
    @State private var showTTS_Tutorial = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImageSelector = false
    @State private var usingCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var navigateToLogin = false
    
    @AppStorage("selectedFont") private var selectedFont: String = "Arial"
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 20
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.cyan]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 220, height: 220)
                        
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.cyan]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 4)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .offset(y: -50)
                    
                    Text("TheraTrack")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
                        .offset(y: -20)
                     
                    Text("Sign Up / Log In:")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)
                        .offset(y: 50)
                        .padding(.bottom, 10)
                    
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                    .hidden()
                    
                    defaultEmailButton(navigateToLogin: $navigateToLogin)
                        .padding(.top, 5)
                        .offset(y: 60)
                    
                    Button(action: {
                        hasSeenOnboarding = false
                    }) {
                        Text("Reset")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.7))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan, lineWidth: 1)
                            )
                    }
                    .padding(.top, 20)
                    .offset(y: 150)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
