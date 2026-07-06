import Foundation

@MainActor
final class CreateExpeditionViewModel: ObservableObject {
    @Published var name = ""
    @Published var optionalDescription = ""
    @Published var startDate = Date()

    var canSave: Bool {
        !trimmedName.isEmpty
    }

    func makeExpedition() -> Expedition? {
        guard canSave else {
            return nil
        }

        return Expedition(
            name: trimmedName,
            optionalDescription: trimmedOptionalDescription,
            startDate: startDate,
            status: .active
        )
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedOptionalDescription: String? {
        let trimmedDescription = optionalDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedDescription.isEmpty ? nil : trimmedDescription
    }
}
