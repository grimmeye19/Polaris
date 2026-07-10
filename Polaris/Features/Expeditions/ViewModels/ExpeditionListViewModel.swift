import Foundation

@MainActor
final class ExpeditionListViewModel: ObservableObject {
    let emptyTitle = "Aún no hay Expediciones"
    let emptyMessage = "Cuando una etapa merezca ser observada con calma, podrás iniciarla aquí."

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func activeExpeditions(from expeditions: [Expedition]) -> [Expedition] {
        expeditions.filter { $0.status == .active }
    }

    func closedExpeditions(from expeditions: [Expedition]) -> [Expedition] {
        expeditions.filter { $0.status == .closed }
    }

    func formattedStartDate(for expedition: Expedition) -> String {
        dateFormatter.string(from: expedition.startDate)
    }

    func statusText(for status: ExpeditionStatus) -> String {
        switch status {
        case .active:
            "Activa"
        case .closed:
            "Cerrada"
        }
    }
}
