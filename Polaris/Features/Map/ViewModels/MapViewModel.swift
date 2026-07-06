import Foundation
import SwiftData

@MainActor
final class MapViewModel: ObservableObject {
    let emptyTitle = "Aun no hay territorio guardado"
    let emptyMessage = "El Mapa crecera cuando guardes lugares, senales, preguntas, simbolos o recursos de esta Expedicion."

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
        case .place:
            "Lugares"
        case .person:
            "Personas"
        case .theme:
            "Temas"
        case .question:
            "Preguntas"
        case .signal:
            "Senales"
        case .resource:
            "Recursos"
        case .obstacle:
            "Obstaculos"
        case .decision:
            "Decisiones"
        case .boundary:
            "Limites"
        case .symbol:
            "Simbolos"
        }
    }

    func shortTitle(for type: MapEntryType) -> String {
        switch type {
        case .place:
            "Lugar"
        case .person:
            "Persona"
        case .theme:
            "Tema"
        case .question:
            "Pregunta"
        case .signal:
            "Senal"
        case .resource:
            "Recurso"
        case .obstacle:
            "Obstaculo"
        case .decision:
            "Decision"
        case .boundary:
            "Limite"
        case .symbol:
            "Simbolo"
        }
    }

    func icon(for type: MapEntryType) -> String {
        switch type {
        case .place:
            "◇"
        case .person:
            "●"
        case .theme:
            "#"
        case .question:
            "?"
        case .signal:
            "~"
        case .resource:
            "+"
        case .obstacle:
            "△"
        case .decision:
            "→"
        case .boundary:
            "|"
        case .symbol:
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
