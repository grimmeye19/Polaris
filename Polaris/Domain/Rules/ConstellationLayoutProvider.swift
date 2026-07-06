import CoreGraphics
import Foundation

enum ConstellationStarWeight {
    case subtle
    case regular
    case bright
}

enum ConstellationLayoutScope {
    case global
    case expedition
}

struct ConstellationMomentSource: Identifiable {
    let id: UUID
    let title: String
    let summary: String
    let occurredAt: Date
    let expeditionID: UUID
    let expeditionName: String
    let weight: ConstellationStarWeight
}

struct ConstellationStar: Identifiable {
    let id: UUID
    let momentID: UUID
    let title: String
    let summary: String
    let occurredAt: Date
    let expeditionID: UUID
    let expeditionName: String
    let x: Double
    let y: Double
    let size: CGFloat
    let opacity: Double
}

struct ConstellationLayoutProvider {
    func stars(from sources: [ConstellationMomentSource], scope: ConstellationLayoutScope) -> [ConstellationStar] {
        let sortedSources = sources.sorted { firstSource, secondSource in
            if firstSource.occurredAt == secondSource.occurredAt {
                return firstSource.id.uuidString < secondSource.id.uuidString
            }

            return firstSource.occurredAt < secondSource.occurredAt
        }

        return sortedSources.enumerated().map { index, source in
            let chronologicalPosition = sortedSources.count <= 1
                ? 0.5
                : Double(index) / Double(sortedSources.count - 1)
            let horizontalDrift = stableFraction(for: source.id, salt: 31)
            let verticalDrift = stableFraction(for: source.id, salt: 67)
            let position = position(
                chronologicalPosition: chronologicalPosition,
                horizontalDrift: horizontalDrift,
                verticalDrift: verticalDrift,
                scope: scope
            )
            let visualWeight = metrics(for: source.weight)

            return ConstellationStar(
                id: source.id,
                momentID: source.id,
                title: source.title,
                summary: source.summary,
                occurredAt: source.occurredAt,
                expeditionID: source.expeditionID,
                expeditionName: source.expeditionName,
                x: position.x,
                y: position.y,
                size: visualWeight.size,
                opacity: visualWeight.opacity
            )
        }
    }

    private func position(
        chronologicalPosition: Double,
        horizontalDrift: Double,
        verticalDrift: Double,
        scope: ConstellationLayoutScope
    ) -> (x: Double, y: Double) {
        switch scope {
        case .global:
            return (
                x: 0.06 + horizontalDrift * 0.88,
                y: 0.08 + ((chronologicalPosition * 0.50) + (verticalDrift * 0.50)) * 0.84
            )
        case .expedition:
            return (
                x: 0.12 + horizontalDrift * 0.76,
                y: 0.14 + ((chronologicalPosition * 0.62) + (verticalDrift * 0.38)) * 0.72
            )
        }
    }

    private func metrics(for weight: ConstellationStarWeight) -> (size: CGFloat, opacity: Double) {
        switch weight {
        case .subtle:
            return (7, 0.62)
        case .regular:
            return (9, 0.78)
        case .bright:
            return (12, 0.96)
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
}
