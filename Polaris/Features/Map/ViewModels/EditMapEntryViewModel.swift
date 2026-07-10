import Foundation
import SwiftData

@MainActor
final class EditMapEntryViewModel: ObservableObject {
    @Published var type: MapEntryType
    @Published var title: String
    @Published var content: String
    @Published private(set) var isSaving = false

    init(entry: MapEntry? = nil) {
        type = entry?.type ?? .detail
        title = entry?.title ?? ""
        content = entry?.content ?? ""
    }

    var canSave: Bool {
        !isSaving && !trimmedTitle.isEmpty
    }

    func saveEntry(for expedition: Expedition, editing entry: MapEntry?, in modelContext: ModelContext) throws {
        guard canSave else {
            throw EditMapEntryError.emptyEntry
        }

        isSaving = true
        defer { isSaving = false }

        if let entry {
            entry.type = type
            entry.title = trimmedTitle
            entry.content = trimmedContent
            entry.updatedAt = Date()
        } else {
            let now = Date()
            let entry = MapEntry(
                expedition: expedition,
                createdAt: now,
                updatedAt: now,
                type: type,
                title: trimmedTitle,
                content: trimmedContent
            )
            modelContext.insert(entry)
        }

        try modelContext.save()
    }

    func title(for type: MapEntryType) -> String {
        type.displayName
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum EditMapEntryError: Error {
    case emptyEntry
}
