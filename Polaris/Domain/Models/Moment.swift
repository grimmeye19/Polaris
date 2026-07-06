import Foundation
import SwiftData

@Model
final class Moment {
    @Attribute(.unique) var id: UUID
    var expedition: Expedition
    var createdAt: Date
    var occurredAt: Date
    var title: String?
    var exteriorText: String
    var interiorText: String
    var freeNotes: String
    var importance: MomentImportance

    init(
        id: UUID = UUID(),
        expedition: Expedition,
        createdAt: Date = Date(),
        occurredAt: Date = Date(),
        title: String? = nil,
        exteriorText: String,
        interiorText: String,
        freeNotes: String = "",
        importance: MomentImportance = .normal
    ) {
        self.id = id
        self.expedition = expedition
        self.createdAt = createdAt
        self.occurredAt = occurredAt
        self.title = title
        self.exteriorText = exteriorText
        self.interiorText = interiorText
        self.freeNotes = freeNotes
        self.importance = importance
    }
}
