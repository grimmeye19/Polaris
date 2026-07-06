import Foundation
import SwiftData

@MainActor
final class MantrasViewModel: ObservableObject {
    @Published var text: String
    @Published private(set) var isSaving = false

    let emptyTitle = "Aun no hay Mantras"
    let emptyMessage = "Conserva frases breves que quieras poder recordar cuando necesites volver a ti."
    let guidance = "Los Mantras hablan del presente. Deben ser cortos, claros y escritos por el Navegante."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(mantra: Mantra? = nil) {
        text = mantra?.text ?? ""
    }

    var canSave: Bool {
        !isSaving && !trimmedText.isEmpty
    }

    func sortedMantras(from mantras: [Mantra]) -> [Mantra] {
        mantras.sorted { firstMantra, secondMantra in
            if firstMantra.updatedAt == secondMantra.updatedAt {
                return firstMantra.text.localizedCaseInsensitiveCompare(secondMantra.text) == .orderedAscending
            }

            return firstMantra.updatedAt > secondMantra.updatedAt
        }
    }

    func save(existing mantra: Mantra?, in modelContext: ModelContext) throws {
        guard canSave else {
            throw MantraEditError.emptyText
        }

        isSaving = true
        defer { isSaving = false }

        let now = Date()

        if let mantra {
            mantra.text = trimmedText
            mantra.updatedAt = now
        } else {
            modelContext.insert(
                Mantra(
                    text: trimmedText,
                    createdAt: now,
                    updatedAt: now
                )
            )
        }

        try modelContext.save()
    }

    func formattedUpdatedAt(for mantra: Mantra) -> String {
        dateFormatter.string(from: mantra.updatedAt)
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum MantraEditError: Error {
    case emptyText
}
