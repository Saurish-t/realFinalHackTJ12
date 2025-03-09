import SwiftUI
import AVKit

struct RecordingView: View {
    var videoURL: URL
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .padding()
                
                Text("Recording Playback")
                    .font(.largeTitle)
                    .padding(.top)
                
                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            )
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView(videoURL: URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2020/10111/33/2D0C46B2-FE80-4038-92E3-E29E6C649471/hls_vod_mvp.m3u8")!)
    }
}
