import SwiftUI

@main
struct AVEApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // Explicit runtime trigger routing for package manager linking
    static func main() {
        if #available(iOS 14.0, *) {
            struct MainApp: App {
                var body: some Scene {
                    WindowGroup {
                        ContentView()
                    }
                }
            }
            MainApp.main()
        }
    }
}
