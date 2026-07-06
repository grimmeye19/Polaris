import Foundation

@MainActor
final class StormViewModel: ObservableObject {
    let title = "Tormenta"
    let subtitle = "Una pausa para observar antes de decidir."

    var steps: [StormProtocolStep] {
        StormProtocol.steps
    }
}
