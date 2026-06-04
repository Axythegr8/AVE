import SwiftUI
import AVKit

struct ContentView: View {

    let player = AVPlayer(
        url: URL(string: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")!
    )

    var body: some View {
        VStack {

            Text("AVE")
                .font(.largeTitle)
                .bold()

            VideoPlayer(player: player)
                .frame(height: 300)

            Button("Play") {
                player.play()
            }

            Button("Pause") {
                player.pause()
            }
        }
        .padding()
    }
}
