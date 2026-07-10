import Foundation
import SwiftData

@MainActor
final class MapViewModel: ObservableObject {
    let emptyTitle = "Aún no hay territorio guardado"
    let emptyMessage = "El Mapa crecerá cuando guardes gustos, fechas, frases, detalles o recuerdos compartidos de esta Expedición."

    private let layoutProvider = MapLayoutProvider()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func entries(for expedition: Expedition) -> [MapEntry] {
        expedition.mapEntries.sorted { firstEntry, secondEntry in
            if firstEntry.updatedAt == secondEntry.updatedAt {
                return firstEntry.title.localizedCaseInsensitiveCompare(secondEntry.title) == .orderedAscending
            }

            return firstEntry.updatedAt > secondEntry.updatedAt
        }
    }

    func nodes(for expedition: Expedition) -> [MapTerritoryNode] {
        layoutProvider.nodes(from: expedition.mapEntries)
    }

    func sections(for expedition: Expedition) -> [MapEntrySection] {
        MapEntryType.allCases.compactMap { type in
            let entries = expedition.mapEntries
                .filter { $0.type == type }
                .sorted { firstEntry, secondEntry in
                    if firstEntry.updatedAt == secondEntry.updatedAt {
                        return firstEntry.title.localizedCaseInsensitiveCompare(secondEntry.title) == .orderedAscending
                    }

                    return firstEntry.updatedAt > secondEntry.updatedAt
                }

            guard !entries.isEmpty else {
                return nil
            }

            return MapEntrySection(
                type: type,
                title: title(for: type),
                entries: entries
            )
        }
    }

    func title(for type: MapEntryType) -> String {
        switch type {
        case .taste:
            "Gustos"
        case .date:
            "Fechas"
        case .quote:
            "Frases"
        case .detail:
            "Detalles"
        case .sensitivity:
            "Sensibilidades"
        case .dreamGoal:
            "Sueños / metas"
        case .us:
            "Nosotros"
        case .other:
            "Otros"
        }
    }

    func shortTitle(for type: MapEntryType) -> String {
        type.displayName
    }

    func icon(for type: MapEntryType) -> String {
        switch type {
        case .taste:
            "◇"
        case .date:
            "●"
        case .quote:
            "#"
        case .detail:
            "?"
        case .sensitivity:
            "~"
        case .dreamGoal:
            "+"
        case .us:
            "△"
        case .other:
            "✦"
        }
    }

    func formattedUpdatedAt(for entry: MapEntry) -> String {
        dateFormatter.string(from: entry.updatedAt)
    }

    func formattedCreatedAt(for node: MapTerritoryNode) -> String {
        dateFormatter.string(from: node.createdAt)
    }

    func entry(for node: MapTerritoryNode, in expedition: Expedition) -> MapEntry? {
        expedition.mapEntries.first { entry in
            entry.id == node.entryID
        }
    }

    func deleteEntries(at offsets: IndexSet, from entries: [MapEntry], in modelContext: ModelContext) throws {
        for index in offsets {
            modelContext.delete(entries[index])
        }

        try modelContext.save()
    }
}

struct MapEntrySection: Identifiable {
    let type: MapEntryType
    let title: String
    let entries: [MapEntry]

    var id: MapEntryType {
        type
    }
}
