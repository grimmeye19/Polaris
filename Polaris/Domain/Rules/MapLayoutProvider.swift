import Foundation

struct MapTerritoryNode: Identifiable {
    let id: UUID
    let entryID: UUID
    let title: String
    let content: String
    let type: MapEntryType
    let createdAt: Date
    let x: Double
    let y: Double
}

struct MapLayoutProvider {
    func nodes(from entries: [MapEntry]) -> [MapTerritoryNode] {
        entries
            .sorted { firstEntry, secondEntry in
                if firstEntry.createdAt == secondEntry.createdAt {
                    return firstEntry.id.uuidString < secondEntry.id.uuidString
                }

                return firstEntry.createdAt < secondEntry.createdAt
            }
            .map { entry in
                let center = regionCenter(for: entry.type)
                let driftX = (stableFraction(for: entry.id, salt: 41) - 0.5) * 0.20
                let driftY = (stableFraction(for: entry.id, salt: 83) - 0.5) * 0.20

                return MapTerritoryNode(
                    id: entry.id,
                    entryID: entry.id,
                    title: entry.title,
                    content: entry.content,
                    type: entry.type,
                    createdAt: entry.createdAt,
                    x: clamp(center.x + driftX),
                    y: clamp(center.y + driftY)
                )
            }
    }

    private func regionCenter(for type: MapEntryType) -> (x: Double, y: Double) {
        switch type {
        case .place:
            return (0.22, 0.22)
        case .person:
            return (0.50, 0.22)
        case .theme:
            return (0.78, 0.22)
        case .question:
            return (0.22, 0.48)
        case .signal:
            return (0.50, 0.48)
        case .resource:
            return (0.78, 0.48)
        case .obstacle:
            return (0.22, 0.74)
        case .decision:
            return (0.50, 0.74)
        case .boundary:
            return (0.68, 0.74)
        case .symbol:
            return (0.84, 0.74)
        }
    }

    private func stableFraction(for id: UUID, salt: UInt64) -> Double {
        var value = UInt64(1_469_598_103_934_665_603) ^ salt

        for scalar in id.uuidString.unicodeScalars {
            value ^= UInt64(scalar.value)
            value &*= 1_099_511_628_211
        }

        return Double(value % 10_000) / 10_000
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0.08), 0.92)
    }
}
