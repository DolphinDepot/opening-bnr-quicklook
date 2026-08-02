import SwiftUI

@main
struct OpeningBNRQuickLookApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                Text("Opening BNR Quick Look")
                    .font(.title2.bold())
                Text("This app adds Finder previews for GameCube's opening.bnr files. Keep it installed, then select a BNR file and press Space.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .frame(width: 440, height: 240)
        }
        .windowResizability(.contentSize)
    }
}
