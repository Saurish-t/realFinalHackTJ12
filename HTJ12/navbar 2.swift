import SwiftUI

struct MainView2: View {
    var body: some View {
        TabView {
            CalendarProgressView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }

            CameraWatcherView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }

            ChatbotView2()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("AI Chat")
                }
        }
        .accentColor(.cyan)
    }
}

#Preview {
    MainView2()
}
