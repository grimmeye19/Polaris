import Foundation
import SwiftData

@MainActor
final class CreateMomentViewModel: ObservableObject {
    @Published var occurredAt = Date()
    @Published var exteriorText = ""
    @Published var interiorText = ""
    @Published var freeNotes = ""
    @Published private(set) var isSaving = false

    var canSave: Bool {
        !isSaving && hasContent
    }

    func makeMoment(for expedition: Expedition) -> Moment? {
        guard hasContent else {
            return nil
        }

        return Moment(
            expedition: expedition,
            occurredAt: occurredAt,
            exteriorText: trimmedExteriorText,
            interiorText: trimmedInteriorText,
            freeNotes: trimmedFreeNotes,
            importance: .normal
        )
    }

    @discardableResult
    func saveMoment(for expedition: Expedition, in modelContext: ModelContext) throws -> Moment {
        guard let moment = makeMoment(for: expedition), !isSaving else {
            throw CreateMomentError.emptyMoment
        }

        isSaving = true
        defer { isSaving = false }

        try MomentPersistence.save(moment, in: modelContext)
        return moment
    }

    private var hasContent: Bool {
        !trimmedExteriorText.isEmpty || !trimmedInteriorText.isEmpty || !trimmedFreeNotes.isEmpty
    }

    private var trimmedExteriorText: String {
        exteriorText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedInteriorText: String {
        interiorText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedFreeNotes: String {
        freeNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum CreateMomentError: Error {
    case emptyMoment
}
