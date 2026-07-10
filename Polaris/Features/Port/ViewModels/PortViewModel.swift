import Foundation

@MainActor
final class PortViewModel: ObservableObject {
    let title = "Puerto"
    let subtitle = "Un lugar para volver antes de seguir navegando."
    let reminder = "El Puerto pertenece al Navegante. Conserva una vista general sin decidir por ti."
    let emptyTitle = "Puerto está en calma"
    let emptyMessage = "Cuando registres Expediciones y Momentos, Puerto podrá mostrarte una vista general de tu navegación."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    let accessItems: [PortAccessItem] = [
        PortAccessItem(
            kind: .navigatorLetter,
            title: "Carta al Navegante",
            subtitle: "Una voz escrita desde la claridad.",
            systemImage: "envelope"
        ),
        PortAccessItem(
            kind: .provisions,
            title: "Provisiones",
            subtitle: "Necesidades, límites y recordatorios propios.",
            systemImage: "backpack"
        ),
        PortAccessItem(
            kind: .mantras,
            title: "Mantras",
            subtitle: "Frases breves para recordar lo importante hoy.",
            systemImage: "compass.drawing"
        )
    ]

    func activeExpeditions(from expeditions: [Expedition]) -> [Expedition] {
        expeditions
            .filter { $0.status == .active }
            .sorted { firstExpedition, secondExpedition in
                firstExpedition.startDate > secondExpedition.startDate
            }
    }

    func activeExpeditionsCount(from expeditions: [Expedition]) -> Int {
        activeExpeditions(from: expeditions).count
    }

    func totalMomentsCount(from moments: [Moment]) -> Int {
        moments.count
    }

    func recentMoments(from moments: [Moment], limit: Int = 5) -> [Moment] {
        Array(
            moments
                .sorted { firstMoment, secondMoment in
                    firstMoment.occurredAt > secondMoment.occurredAt
                }
                .prefix(limit)
        )
    }

    func lastMomentDate(from moments: [Moment]) -> Date? {
        moments.max { firstMoment, secondMoment in
            firstMoment.occurredAt < secondMoment.occurredAt
        }?.occurredAt
    }

    func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    func title(for moment: Moment) -> String {
        guard let title = moment.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Momento"
        }

        return title
    }

    func summary(for moment: Moment) -> String {
        if !moment.exteriorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return moment.exteriorText
        }

        if !moment.interiorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return moment.interiorText
        }

        return "Momento conservado."
    }
}

struct PortAccessItem: Identifiable, Hashable {
    let kind: PortAccessKind
    let title: String
    let subtitle: String
    let systemImage: String

    var id: PortAccessKind { kind }
}

enum PortAccessKind: Hashable {
    case navigatorLetter
    case provisions
    case mantras
}
