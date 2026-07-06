import Foundation
import SwiftData

@MainActor
final class ExpeditionSettingsViewModel: ObservableObject {
    @Published private(set) var isSaving = false

    let activeMessage = "Cerrar una Expedicion detiene nuevos Momentos, pero su Historia y su Mapa permanecen consultables."
    let closedMessage = "Esta Expedicion ya esta cerrada. Su memoria permanece disponible para volver a ella con calma."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func close(expedition: Expedition, in modelContext: ModelContext) throws {
        guard expedition.status == .active else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        expedition.status = .closed
        expedition.closedAt = Date()

        try modelContext.save()
    }

    func statusText(for expedition: Expedition) -> String {
        switch expedition.status {
        case .active:
            "Activa"
        case .closed:
            "Cerrada"
        }
    }

    func closedAtText(for expedition: Expedition) -> String {
        guard let closedAt = expedition.closedAt else {
            return "Sin cierre registrado"
        }

        return dateFormatter.string(from: closedAt)
    }
}
