import Foundation

@MainActor
final class MapViewModel: ObservableObject {
    let emptyTitle = "Aun no hay entradas en el Mapa"
    let emptyMessage = "El Mapa crecera cuando conserves conocimiento acumulado de esta Expedicion."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

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
        case .gusto:
            "Gustos"
        case .fecha:
            "Fechas"
        case .frase:
            "Frases"
        case .detalle:
            "Detalles"
        case .sensibilidad:
            "Sensibilidades"
        case .suenoMeta:
            "Suenos/metas"
        case .nosotros:
            "Nosotros"
        case .otro:
            "Otro"
        }
    }

    func formattedUpdatedAt(for entry: MapEntry) -> String {
        dateFormatter.string(from: entry.updatedAt)
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
