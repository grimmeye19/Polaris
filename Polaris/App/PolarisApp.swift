import SwiftUI
import SwiftData

@main
struct PolarisApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PolarisModelContainer.shared)
    }
}
