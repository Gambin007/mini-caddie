import SwiftUI

// Start der App. @main = Einstiegspunkt.
// WindowGroup ist auf dem iPhone einfach der Vollbild-Screen.
// Wichtig: es darf nur ein @main im Projekt geben.
@main
struct MiniCaddieApp: App {
    var body: some Scene {
        WindowGroup {
            CaddieView()
        }
    }
}
