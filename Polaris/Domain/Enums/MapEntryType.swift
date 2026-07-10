enum MapEntryType: String, Codable, CaseIterable {
    case taste
    case date
    case quote
    case detail
    case sensitivity
    case dreamGoal
    case us
    case other

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = MapEntryType(rawValue: rawValue) ?? .other
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var displayName: String {
        switch self {
        case .taste:
            "Gusto"
        case .date:
            "Fecha"
        case .quote:
            "Frase"
        case .detail:
            "Detalle"
        case .sensitivity:
            "Sensibilidad"
        case .dreamGoal:
            "Sueño / meta"
        case .us:
            "Nosotros"
        case .other:
            "Otro"
        }
    }
}
