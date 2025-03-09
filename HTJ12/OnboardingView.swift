//
//  OnboardingView.swift
//  biofreeze
//
//  Created by Saurish Tripathi on 3/8/25.
//


import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var gradientColors: [Color] = [Color.cyan, Color.white]

    struct OnboardingPage {
        let title: String
        let description: String
        let imageName: String
    }
    
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to TheraTrack", description: "Your AI-powered coach for personalized communication improvement.", imageName: "waveform.path.ecg"),
        OnboardingPage(title: "Improve How You Communicate", description: "Upload videos of yourself and get feedback on your facial cues, nervous gestures, and emotional signals.", imageName: "face.smiling"),
        OnboardingPage(title: "Personalized Daily Tracking", description: "Monitor your progress over time with daily videos and AI analysis showing your improvement journey.", imageName: "chart.line.uptrend.xyaxis"),
        OnboardingPage(title: "Your Personal AI Coach", description: "Chat with our AI assistant for real-time feedback and personalized communication tips.", imageName: "bubble.left.and.bubble.right.fill")
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: pages[currentPage].imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .transition(.opacity)

                Text(pages[currentPage].title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .transition(.opacity)

                Text(pages[currentPage].description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .transition(.opacity)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \..self) { index in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(index == currentPage ? .white : .white.opacity(0.5))
                    }
                }

                Button(action: nextPage) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 40)
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
            }
            .padding()
            .transition(.opacity)
        }
        .animation(.spring(), value: currentPage)
    }

    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            gradientColors = gradientColors.reversed()
        } else {
            hasSeenOnboarding = true
        }
    }
}
