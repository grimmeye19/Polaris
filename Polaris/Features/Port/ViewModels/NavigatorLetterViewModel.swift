import Foundation
import SwiftData

@MainActor
final class NavigatorLetterViewModel: ObservableObject {
    @Published var content = ""
    @Published private(set) var isSaving = false
    @Published private(set) var hasLoaded = false

    let guidance = "Escribe desde un momento de claridad. Esta Carta habla de ti, no de una Expedición ni de otra persona."
    let placeholder = "Quién quiero seguir siendo...\n\nQué necesito recordar cuando me pierdo en una Expedición...\n\nQué cosas no quiero abandonar de mí..."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var canSave: Bool {
        !isSaving
    }

    func loadIfNeeded(from letter: NavigatorLetter?) {
        guard !hasLoaded else {
            return
        }

        content = letter?.content ?? ""
        hasLoaded = true
    }

    func save(existing letter: NavigatorLetter?, in modelContext: ModelContext) throws {
        guard canSave else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        let now = Date()

        if let letter {
            letter.content = content
            letter.updatedAt = now
        } else {
            modelContext.insert(
                NavigatorLetter(
                    content: content,
                    updatedAt: now
                )
            )
        }

        try modelContext.save()
    }

    func updatedAtText(for letter: NavigatorLetter?) -> String {
        guard let letter else {
            return "Aún no guardada"
        }

        return "Actualizada \(dateFormatter.string(from: letter.updatedAt))"
    }
}
