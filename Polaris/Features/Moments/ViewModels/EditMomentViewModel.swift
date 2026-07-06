import Foundation
import SwiftData

@MainActor
final class EditMomentViewModel: ObservableObject {
    @Published var occurredAt: Date
    @Published var title: String
    @Published var exteriorText: String
    @Published var interiorText: String
    @Published var freeNotes: String
    @Published private(set) var isSaving = false

    init(moment: Moment) {
        occurredAt = moment.occurredAt
        title = moment.title ?? ""
        exteriorText = moment.exteriorText
        interiorText = moment.interiorText
        freeNotes = moment.freeNotes
    }

    var canSave: Bool {
        !isSaving && hasContent
    }

    func saveChanges(to moment: Moment, in modelContext: ModelContext) throws {
        guard canSave else {
            throw EditMomentError.emptyMoment
        }

        isSaving = true
        defer { isSaving = false }

        moment.occurredAt = occurredAt
        moment.title = trimmedTitle.isEmpty ? nil : trimmedTitle
        moment.exteriorText = trimmedExteriorText
        moment.interiorText = trimmedInteriorText
        moment.freeNotes = trimmedFreeNotes

        try modelContext.save()
    }

    private var hasContent: Bool {
        !trimmedExteriorText.isEmpty || !trimmedInteriorText.isEmpty || !trimmedFreeNotes.isEmpty
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
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

enum EditMomentError: Error {
    case emptyMoment
}
