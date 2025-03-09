import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        } else {
            MainView()
        }
    }
}
#Preview {
    ContentView()
}


