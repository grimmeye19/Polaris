import SwiftData
import SwiftUI

struct CurrentsView: View {
    let expedition: Expedition

    @Query(sort: \Moment.occurredAt, order: .forward) private var globalMoments: [Moment]
    @StateObject private var viewModel = CurrentsViewModel()

    init(expedition: Expedition) {
        self.expedition = expedition
    }

    var body: some View {
        let summary = viewModel.summary(for: expedition, globalMoments: globalMoments)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if summary.totalMoments == 0 {
                    emptyState
                } else {
                    summarySection(summary)
                    recentMovementSection(summary.recentMovement)
                    importanceSection(summary.importanceDistribution)
                    tagsSection(summary.frequentTags)
                    rhythmSection(summary)
                    concentrationSection(summary)
                    comparisonSection(summary.comparison)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Corrientes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Corrientes")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("Patrones observados a partir de tus Momentos.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            title: viewModel.emptyTitle,
            message: viewModel.emptyMessage,
            systemImage: "waveform.path.ecg"
        )
    }

    private func summarySection(_ summary: CurrentsSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                CurrentsMetricCard(title: "Momentos", value: "\(summary.totalMoments)", subtitle: "Registrados")
                CurrentsMetricCard(title: "Promedio semanal", value: viewModel.formattedDecimal(summary.averageMomentsPerWeek), subtitle: "Momentos")
            }

            if let lastMomentDate = summary.lastMomentDate {
                CurrentsInfoRow(title: "Último Momento", value: viewModel.formattedDate(lastMomentDate))
            }

            CurrentsInfoRow(title: "Últimos 30 días", value: "\(summary.recentMovement.lastThirtyDays) Momentos")
        }
    }

    private func recentMovementSection(_ movement: RecentMovement) -> some View {
        CurrentsSection(title: "Movimiento reciente") {
            VStack(alignment: .leading, spacing: 12) {
                CurrentsInfoRow(title: "Últimos 7 días", value: "\(movement.lastSevenDays)")
                CurrentsInfoRow(title: "7 días anteriores", value: "\(movement.previousSevenDays)")

                Text(viewModel.movementText(for: movement))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func importanceSection(_ importance: ImportanceDistribution?) -> some View {
        if let importance {
            CurrentsSection(title: "Importancia registrada") {
                VStack(alignment: .leading, spacing: 12) {
                    CurrentsInfoRow(title: "Promedio", value: "\(viewModel.formattedDecimal(importance.average)) / 3")
                    CurrentsInfoRow(title: "Máximo", value: viewModel.importanceName(for: importance.maximum))
                    CurrentsInfoRow(title: "Mediana", value: viewModel.formattedDecimal(importance.median))

                    CurrentsBarRow(title: "Baja", count: importance.low, maxCount: max(importance.low, importance.normal, importance.high))
                    CurrentsBarRow(title: "Media", count: importance.normal, maxCount: max(importance.low, importance.normal, importance.high))
                    CurrentsBarRow(title: "Alta", count: importance.high, maxCount: max(importance.low, importance.normal, importance.high))
                }
            }
        }
    }

    private func tagsSection(_ tags: [FrequentTag]) -> some View {
        CurrentsSection(title: "Etiquetas frecuentes") {
            if tags.isEmpty {
                Text("No hay etiquetas registradas en Momentos todavía.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tags) { tag in
                        CurrentsInfoRow(title: tag.tag, value: "\(tag.count)")
                    }
                }
            }
        }
    }

    private func rhythmSection(_ summary: CurrentsSummary) -> some View {
        CurrentsSection(title: "Ritmo temporal") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.topWeekdays(from: summary)) { weekday in
                    CurrentsBarRow(
                        title: viewModel.weekdayName(for: weekday.weekday),
                        count: weekday.count,
                        maxCount: summary.weekdayDistribution.map(\.count).max() ?? 1
                    )
                }

                if let topTimeOfDay = viewModel.topTimeOfDay(from: summary), topTimeOfDay.count > 0 {
                    CurrentsInfoRow(
                        title: "Momento del dia",
                        value: "\(viewModel.timeOfDayName(for: topTimeOfDay.bucket)) · \(topTimeOfDay.count)"
                    )
                }
            }
        }
    }

    private func concentrationSection(_ summary: CurrentsSummary) -> some View {
        CurrentsSection(title: "Concentración") {
            VStack(alignment: .leading, spacing: 10) {
                if let tagPercentage = summary.concentration.topThreeTagsPercentage {
                    CurrentsInfoRow(title: "Top etiquetas", value: viewModel.formattedPercentage(tagPercentage))
                } else {
                    Text("No hay etiquetas suficientes para esta lectura.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let weekdayPercentage = summary.concentration.topThreeWeekdaysPercentage {
                    CurrentsInfoRow(title: "Top días", value: viewModel.formattedPercentage(weekdayPercentage))
                }
            }
        }
    }

    @ViewBuilder
    private func comparisonSection(_ comparison: ExpeditionComparison?) -> some View {
        if let comparison {
            CurrentsSection(title: "Comparación descriptiva") {
                VStack(alignment: .leading, spacing: 12) {
                    CurrentsInfoRow(
                        title: "Esta Expedición",
                        value: "\(viewModel.formattedDecimal(comparison.expeditionMomentsPerWeek)) Momentos/semana"
                    )
                    CurrentsInfoRow(
                        title: "Promedio global",
                        value: "\(viewModel.formattedDecimal(comparison.globalMomentsPerWeek)) Momentos/semana"
                    )

                    if let expeditionAverage = comparison.expeditionImportanceAverage,
                       let globalAverage = comparison.globalImportanceAverage {
                        CurrentsInfoRow(
                            title: "Importancia media",
                            value: "\(viewModel.formattedDecimal(expeditionAverage)) vs \(viewModel.formattedDecimal(globalAverage))"
                        )
                    }
                }
            }
        }
    }
}

private struct CurrentsSection<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            CurrentsCard {
                content()
            }
        }
    }
}

private struct CurrentsCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

private struct CurrentsMetricCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        CurrentsCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct CurrentsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

private struct CurrentsBarRow: View {
    let title: String
    let count: Int
    let maxCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(count)")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue.opacity(0.18))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.62))
                            .frame(width: proxy.size.width * widthRatio)
                    }
            }
            .frame(height: 8)
        }
    }

    private var widthRatio: Double {
        guard maxCount > 0 else {
            return 0
        }

        return Double(count) / Double(maxCount)
    }
}

#Preview {
    NavigationStack {
        CurrentsView(expedition: Expedition(name: "Una etapa importante"))
            .modelContainer(PolarisModelContainer.shared)
    }
}
