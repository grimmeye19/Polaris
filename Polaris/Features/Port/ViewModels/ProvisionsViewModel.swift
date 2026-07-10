import Foundation
import SwiftData

@MainActor
final class ProvisionsViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    @Published var category: String
    @Published private(set) var isSaving = false

    let emptyTitle = "Aún no hay Provisiones"
    let emptyMessage = "Conserva aquí necesidades, límites y recordatorios que pertenecen al Navegante."
    let guidance = "Las Provisiones hablan de lo que necesitas proteger para no perderte a ti mismo."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(provision: Provision? = nil) {
        title = provision?.title ?? ""
        content = provision?.content ?? ""
        category = provision?.category ?? ""
    }

    var canSave: Bool {
        !isSaving && !trimmedTitle.isEmpty
    }

    func sortedProvisions(from provisions: [Provision]) -> [Provision] {
        provisions.sorted { firstProvision, secondProvision in
            if firstProvision.updatedAt == secondProvision.updatedAt {
                return firstProvision.title.localizedCaseInsensitiveCompare(secondProvision.title) == .orderedAscending
            }

            return firstProvision.updatedAt > secondProvision.updatedAt
        }
    }

    func save(existing provision: Provision?, in modelContext: ModelContext) throws {
        guard canSave else {
            throw ProvisionEditError.emptyTitle
        }

        isSaving = true
        defer { isSaving = false }

        let now = Date()

        if let provision {
            provision.title = trimmedTitle
            provision.content = trimmedOptionalContent
            provision.category = trimmedOptionalCategory
            provision.updatedAt = now
        } else {
            modelContext.insert(
                Provision(
                    title: trimmedTitle,
                    content: trimmedOptionalContent,
                    category: trimmedOptionalCategory,
                    createdAt: now,
                    updatedAt: now
                )
            )
        }

        try modelContext.save()
    }

    func formattedUpdatedAt(for provision: Provision) -> String {
        dateFormatter.string(from: provision.updatedAt)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedOptionalContent: String? {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedContent.isEmpty ? nil : trimmedContent
    }

    private var trimmedOptionalCategory: String? {
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedCategory.isEmpty ? nil : trimmedCategory
    }
}

enum ProvisionEditError: Error {
    case emptyTitle
}
