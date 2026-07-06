import Foundation
import SwiftData

@Model
final class Provision {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String?
    var category: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String? = nil,
        category: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
