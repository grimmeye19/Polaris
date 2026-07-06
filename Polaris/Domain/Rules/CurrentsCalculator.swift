import Foundation

struct CurrentsSummary {
    let totalMoments: Int
    let weeklyCounts: [PeriodCount]
    let averageMomentsPerWeek: Double
    let importanceDistribution: ImportanceDistribution?
    let frequentTags: [FrequentTag]
    let recentMovement: RecentMovement
    let weekdayDistribution: [WeekdayDistribution]
    let timeOfDayDistribution: [TimeOfDayDistribution]
    let concentration: CurrentsConcentration
    let comparison: ExpeditionComparison?
    let lastMomentDate: Date?
}

struct PeriodCount: Identifiable {
    let periodStart: Date
    let count: Int

    var id: Date { periodStart }
}

struct ImportanceDistribution {
    let low: Int
    let normal: Int
    let high: Int
    let average: Double
    let maximum: Int
    let median: Double
}

struct FrequentTag: Identifiable {
    let tag: String
    let count: Int

    var id: String { tag }
}

struct TimeOfDayDistribution: Identifiable {
    let bucket: TimeOfDayBucket
    let count: Int

    var id: TimeOfDayBucket { bucket }
}

struct WeekdayDistribution: Identifiable {
    let weekday: Int
    let count: Int

    var id: Int { weekday }
}

struct RecentMovement {
    let lastSevenDays: Int
    let previousSevenDays: Int
    let absoluteChange: Int
    let percentageChange: Double?
    let lastThirtyDays: Int
}

struct CurrentsConcentration {
    let topThreeTagsPercentage: Double?
    let topThreeWeekdaysPercentage: Double?
}

struct ExpeditionComparison {
    let expeditionMomentsPerWeek: Double
    let globalMomentsPerWeek: Double
    let expeditionImportanceAverage: Double?
    let globalImportanceAverage: Double?
}

enum TimeOfDayBucket: CaseIterable {
    case earlyMorning
    case morning
    case afternoon
    case night
}

struct CurrentsCalculator {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func summary(for moments: [Moment], globalMoments: [Moment] = [], referenceDate: Date = Date()) -> CurrentsSummary {
        let sortedMoments = moments.sorted { $0.occurredAt < $1.occurredAt }
        let importance = importanceDistribution(for: sortedMoments)
        let weekdayDistribution = weekdayDistribution(for: sortedMoments)
        let tagCounts: [FrequentTag] = []

        return CurrentsSummary(
            totalMoments: sortedMoments.count,
            weeklyCounts: weeklyCounts(for: sortedMoments),
            averageMomentsPerWeek: averageMomentsPerWeek(for: sortedMoments),
            importanceDistribution: importance,
            frequentTags: tagCounts,
            recentMovement: recentMovement(for: sortedMoments, referenceDate: referenceDate),
            weekdayDistribution: weekdayDistribution,
            timeOfDayDistribution: timeOfDayDistribution(for: sortedMoments),
            concentration: CurrentsConcentration(
                topThreeTagsPercentage: nil,
                topThreeWeekdaysPercentage: concentrationPercentage(from: weekdayDistribution.map(\.count), total: sortedMoments.count)
            ),
            comparison: comparison(for: sortedMoments, globalMoments: globalMoments),
            lastMomentDate: sortedMoments.last?.occurredAt
        )
    }

    private func weeklyCounts(for moments: [Moment]) -> [PeriodCount] {
        let grouped = Dictionary(grouping: moments) { moment in
            calendar.dateInterval(of: .weekOfYear, for: moment.occurredAt)?.start ?? calendar.startOfDay(for: moment.occurredAt)
        }

        return grouped
            .map { PeriodCount(periodStart: $0.key, count: $0.value.count) }
            .sorted { $0.periodStart < $1.periodStart }
    }

    private func averageMomentsPerWeek(for moments: [Moment]) -> Double {
        guard !moments.isEmpty else {
            return 0
        }

        let weeks = max(weeklyCounts(for: moments).count, 1)
        return Double(moments.count) / Double(weeks)
    }

    private func importanceDistribution(for moments: [Moment]) -> ImportanceDistribution? {
        guard !moments.isEmpty else {
            return nil
        }

        let values = moments.map { numericImportance(for: $0.importance) }.sorted()
        let middle = values.count / 2
        let median = values.count.isMultiple(of: 2)
            ? Double(values[middle - 1] + values[middle]) / 2.0
            : Double(values[middle])

        return ImportanceDistribution(
            low: moments.filter { $0.importance == .low }.count,
            normal: moments.filter { $0.importance == .normal }.count,
            high: moments.filter { $0.importance == .high }.count,
            average: Double(values.reduce(0, +)) / Double(values.count),
            maximum: values.max() ?? 0,
            median: median
        )
    }

    private func recentMovement(for moments: [Moment], referenceDate: Date) -> RecentMovement {
        let lastSevenStart = calendar.date(byAdding: .day, value: -7, to: referenceDate) ?? referenceDate
        let previousSevenStart = calendar.date(byAdding: .day, value: -14, to: referenceDate) ?? referenceDate
        let lastThirtyStart = calendar.date(byAdding: .day, value: -30, to: referenceDate) ?? referenceDate

        let lastSeven = moments.filter { $0.occurredAt >= lastSevenStart && $0.occurredAt <= referenceDate }.count
        let previousSeven = moments.filter { $0.occurredAt >= previousSevenStart && $0.occurredAt < lastSevenStart }.count
        let lastThirty = moments.filter { $0.occurredAt >= lastThirtyStart && $0.occurredAt <= referenceDate }.count
        let change = lastSeven - previousSeven
        let percentage = previousSeven == 0 ? nil : (Double(change) / Double(previousSeven)) * 100.0

        return RecentMovement(
            lastSevenDays: lastSeven,
            previousSevenDays: previousSeven,
            absoluteChange: change,
            percentageChange: percentage,
            lastThirtyDays: lastThirty
        )
    }

    private func weekdayDistribution(for moments: [Moment]) -> [WeekdayDistribution] {
        let grouped = Dictionary(grouping: moments) { moment in
            calendar.component(.weekday, from: moment.occurredAt)
        }

        return (1...7).map { weekday in
            WeekdayDistribution(weekday: weekday, count: grouped[weekday]?.count ?? 0)
        }
    }

    private func timeOfDayDistribution(for moments: [Moment]) -> [TimeOfDayDistribution] {
        let grouped = Dictionary(grouping: moments) { moment in
            timeOfDayBucket(for: moment.occurredAt)
        }

        return TimeOfDayBucket.allCases.map { bucket in
            TimeOfDayDistribution(bucket: bucket, count: grouped[bucket]?.count ?? 0)
        }
    }

    private func comparison(for moments: [Moment], globalMoments: [Moment]) -> ExpeditionComparison? {
        guard !moments.isEmpty, !globalMoments.isEmpty else {
            return nil
        }

        return ExpeditionComparison(
            expeditionMomentsPerWeek: averageMomentsPerWeek(for: moments),
            globalMomentsPerWeek: averageMomentsPerWeek(for: globalMoments),
            expeditionImportanceAverage: importanceDistribution(for: moments)?.average,
            globalImportanceAverage: importanceDistribution(for: globalMoments)?.average
        )
    }

    private func concentrationPercentage(from counts: [Int], total: Int) -> Double? {
        guard total > 0 else {
            return nil
        }

        let topThree = counts.sorted(by: >).prefix(3).reduce(0, +)
        return (Double(topThree) / Double(total)) * 100.0
    }

    private func timeOfDayBucket(for date: Date) -> TimeOfDayBucket {
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        case 18..<24:
            return .night
        default:
            return .earlyMorning
        }
    }

    private func numericImportance(for importance: MomentImportance) -> Int {
        switch importance {
        case .low:
            return 1
        case .normal:
            return 2
        case .high:
            return 3
        }
    }
}
