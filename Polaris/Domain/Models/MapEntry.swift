import Foundation
import SwiftData

@Model
final class MapEntry {
    @Attribute(.unique) var id: UUID
    var expedition: Expedition
    var createdAt: Date
    var updatedAt: Date
    var type: MapEntryType
    var title: String
    var content: String

    init(
        id: UUID = UUID(),
        expedition: Expedition,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        type: MapEntryType,
        title: String,
        content: String
    ) {
        self.id = id
        self.expedition = expedition
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.type = type
        self.title = title
        self.content = content
    }
}
