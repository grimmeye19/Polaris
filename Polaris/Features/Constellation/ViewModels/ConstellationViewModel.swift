import Foundation

enum ConstellationScope {
    case global
    case expedition(Expedition)
}

@MainActor
final class ConstellationViewModel: ObservableObject {
    let scope: ConstellationScope

    private let layoutProvider = ConstellationLayoutProvider()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(scope: ConstellationScope) {
        self.scope = scope
    }

    var title: String {
        switch scope {
        case .global:
            return "Constelación"
        case .expedition:
            return "Constelación"
        }
    }

    var emptyTitle: String {
        "Aún no hay estrellas"
    }

    var emptyMessage: String {
        switch scope {
        case .global:
            return "El cielo del Navegante aparecerá cuando existan Momentos registrados."
        case .expedition:
            return "La Constelación aparecerá cuando esta Expedición tenga Momentos registrados."
        }
    }

    var headerTitle: String {
        switch scope {
        case .global:
            return "Cielo del Navegante"
        case .expedition(let expedition):
            return expedition.name
        }
    }

    func stars(allMoments: [Moment]) -> [ConstellationStar] {
        let moments: [Moment]
        let layoutScope: ConstellationLayoutScope

        switch scope {
        case .global:
            moments = allMoments
            layoutScope = .global
        case .expedition(let expedition):
            moments = expedition.moments
            layoutScope = .expedition
        }

        return layoutProvider.stars(
            from: moments.map { moment in
                ConstellationMomentSource(
                    id: moment.id,
                    title: momentTitle(for: moment),
                    summary: summary(for: moment),
                    occurredAt: moment.occurredAt,
                    expeditionID: moment.expedition.id,
                    expeditionName: moment.expedition.name,
                    weight: weight(for: moment.importance)
                )
            },
            scope: layoutScope
        )
    }

    func moment(for star: ConstellationStar) -> Moment? {
        guard case .expedition(let expedition) = scope else {
            return nil
        }

        return expedition.moments.first { moment in
            moment.id == star.momentID
        }
    }

    func expedition(for star: ConstellationStar, in expeditions: [Expedition]) -> Expedition? {
        expeditions.first { expedition in
            expedition.id == star.expeditionID
        }
    }

    func formattedDate(for star: ConstellationStar) -> String {
        dateFormatter.string(from: star.occurredAt)
    }

    private func momentTitle(for moment: Moment) -> String {
        guard let title = moment.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Momento"
        }

        return title
    }

    private func summary(for moment: Moment) -> String {
        if !moment.exteriorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return moment.exteriorText
        }

        if !moment.interiorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return moment.interiorText
        }

        if !moment.freeNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return moment.freeNotes
        }

        return "Momento conservado en esta Expedición."
    }

    private func weight(for importance: MomentImportance) -> ConstellationStarWeight {
        switch importance {
        case .low:
            return .subtle
        case .normal:
            return .regular
        case .high:
            return .bright
        }
    }
}
