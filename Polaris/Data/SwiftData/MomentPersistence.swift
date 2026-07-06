import SwiftData

enum MomentPersistence {
    @MainActor
    static func save(_ moment: Moment, in modelContext: ModelContext) throws {
        modelContext.insert(moment)
        try modelContext.save()
    }
}
