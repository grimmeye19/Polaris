import Foundation

enum ExpeditionNavigationDestination: String, Identifiable {
    case registerMoment
    case history

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .registerMoment:
            "Registrar Momento"
        case .history:
            "Historia"
        }
    }

    var unavailableMessage: String {
        switch self {
        case .registerMoment:
            "El registro de Momentos se implementara en la siguiente mision."
        case .history:
            "La Historia se activará cuando existan Momentos dentro de la Expedición."
        }
    }
}
