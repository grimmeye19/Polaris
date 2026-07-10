import Foundation

@MainActor
final class CurrentsViewModel: ObservableObject {
    let emptyTitle = "No hay Momentos registrados todavía"
    let emptyMessage = "Cuando registres más Momentos, Corrientes podrá mostrar tendencias simples."

    private let calculator = CurrentsCalculator()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    func summary(for expedition: Expedition, globalMoments: [Moment]) -> CurrentsSummary {
        calculator.summary(for: expedition.moments, globalMoments: globalMoments)
    }

    func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    func formattedPeriod(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

    func formattedDecimal(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    func formattedPercentage(_ value: Double) -> String {
        String(format: "%.0f%%", value)
    }

    func movementText(for movement: RecentMovement) -> String {
        if movement.absoluteChange == 0 {
            return "Sin cambio respecto al período anterior."
        }

        let direction = movement.absoluteChange > 0 ? "más" : "menos"
        let absolute = abs(movement.absoluteChange)

        if let percentage = movement.percentageChange {
            return "\(absolute) \(direction) que el período anterior (\(formattedPercentage(abs(percentage))))."
        }

        return "\(absolute) \(direction) que el período anterior."
    }

    func importanceName(for value: Int) -> String {
        switch value {
        case 1:
            return "Baja"
        case 3:
            return "Alta"
        default:
            return "Media"
        }
    }

    func weekdayName(for weekday: Int) -> String {
        let symbols = Calendar.current.shortWeekdaySymbols
        guard symbols.indices.contains(weekday - 1) else {
            return "\(weekday)"
        }

        return symbols[weekday - 1].capitalized
    }

    func timeOfDayName(for bucket: TimeOfDayBucket) -> String {
        switch bucket {
        case .earlyMorning:
            return "Madrugada"
        case .morning:
            return "Mañana"
        case .afternoon:
            return "Tarde"
        case .night:
            return "Noche"
        }
    }

    func topWeekdays(from summary: CurrentsSummary) -> [WeekdayDistribution] {
        summary.weekdayDistribution
            .filter { $0.count > 0 }
            .sorted { first, second in
                if first.count == second.count {
                    return first.weekday < second.weekday
                }

                return first.count > second.count
            }
            .prefix(3)
            .map { $0 }
    }

    func topTimeOfDay(from summary: CurrentsSummary) -> TimeOfDayDistribution? {
        summary.timeOfDayDistribution.max { first, second in
            first.count < second.count
        }
    }
}
