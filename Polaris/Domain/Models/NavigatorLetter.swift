import Foundation
import SwiftData

@Model
final class NavigatorLetter {
    @Attribute(.unique) var id: UUID
    var content: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        content: String = "",
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.updatedAt = updatedAt
    }
}
