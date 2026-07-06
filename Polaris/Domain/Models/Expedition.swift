import Foundation
import SwiftData

@Model
final class Expedition {
    @Attribute(.unique) var id: UUID
    var name: String
    var optionalDescription: String?
    var createdAt: Date
    var startDate: Date
    var closedAt: Date?
    var status: ExpeditionStatus
    @Relationship(deleteRule: .cascade, inverse: \Moment.expedition) var moments: [Moment]
    @Relationship(deleteRule: .cascade, inverse: \MapEntry.expedition) var mapEntries: [MapEntry]

    init(
        id: UUID = UUID(),
        name: String,
        optionalDescription: String? = nil,
        createdAt: Date = Date(),
        startDate: Date = Date(),
        closedAt: Date? = nil,
        status: ExpeditionStatus = .active,
        moments: [Moment] = [],
        mapEntries: [MapEntry] = []
    ) {
        self.id = id
        self.name = name
        self.optionalDescription = optionalDescription
        self.createdAt = createdAt
        self.startDate = startDate
        self.closedAt = closedAt
        self.status = status
        self.moments = moments
        self.mapEntries = mapEntries
    }
}
