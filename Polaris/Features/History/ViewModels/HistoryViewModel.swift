import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    let emptyTitle = "Aun no hay Momentos"
    let emptyMessage = "La Historia se construira cuando registres el primer Momento de esta Expedicion."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    func sortedMoments(for expedition: Expedition) -> [Moment] {
        expedition.moments.sorted { firstMoment, secondMoment in
            firstMoment.occurredAt < secondMoment.occurredAt
        }
    }

    func formattedOccurredAt(for moment: Moment) -> String {
        dateFormatter.string(from: moment.occurredAt)
    }

    func title(for moment: Moment) -> String {
        guard let title = moment.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Momento"
        }

        return title
    }
}
