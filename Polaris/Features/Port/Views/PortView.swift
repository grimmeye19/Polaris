import SwiftData
import SwiftUI

struct PortView: View {
    @Query(sort: \Expedition.startDate, order: .reverse) private var expeditions: [Expedition]
    @Query(sort: \Moment.occurredAt, order: .reverse) private var moments: [Moment]

    @StateObject private var viewModel = PortViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    summarySection
                    globalAccess
                    activeExpeditionsSection
                    recentMomentsSection
                    accessList
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.title)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Puerto")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.reminder)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemGroupedBackground))
                )

            if expeditions.isEmpty && moments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.emptyTitle)
                        .font(.headline)

                    Text(viewModel.emptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vista general")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                PortSummaryCardView(
                    title: "Activas",
                    value: "\(viewModel.activeExpeditionsCount(from: expeditions))",
                    subtitle: "Expediciones"
                )

                PortSummaryCardView(
                    title: "Momentos",
                    value: "\(viewModel.totalMomentsCount(from: moments))",
                    subtitle: "Registrados"
                )
            }

            if let lastMomentDate = viewModel.lastMomentDate(from: moments) {
                PortInfoCardView(
                    title: "Ultimo Momento",
                    subtitle: viewModel.formattedDate(lastMomentDate),
                    systemImage: "clock"
                )
            }
        }
    }

    private var globalAccess: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cielo del Navegante")
                .font(.headline)

            NavigationLink {
                ConstellationView(scope: .global)
            } label: {
                PortInfoCardView(
                    title: "Ver Constelacion",
                    subtitle: "Una vista serena de los Momentos conservados.",
                    systemImage: "sparkles"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var activeExpeditionsSection: some View {
        let activeExpeditions = viewModel.activeExpeditions(from: expeditions)

        return Group {
            if !activeExpeditions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Expediciones activas")
                        .font(.headline)

                    ForEach(activeExpeditions) { expedition in
                        NavigationLink {
                            ExpeditionDetailView(expedition: expedition)
                        } label: {
                            PortInfoCardView(
                                title: expedition.name,
                                subtitle: expedition.optionalDescription ?? "Expedicion en curso.",
                                systemImage: "sailboat"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var recentMomentsSection: some View {
        let recentMoments = viewModel.recentMoments(from: moments)

        return Group {
            if !recentMoments.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Momentos recientes")
                        .font(.headline)

                    ForEach(recentMoments) { moment in
                        NavigationLink {
                            ExpeditionDetailView(expedition: moment.expedition)
                        } label: {
                            PortMomentRowView(
                                title: viewModel.title(for: moment),
                                summary: viewModel.summary(for: moment),
                                expeditionName: moment.expedition.name,
                                dateText: viewModel.formattedDate(moment.occurredAt)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var accessList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recursos del Puerto")
                .font(.headline)

            ForEach(viewModel.accessItems) { item in
                NavigationLink {
                    destination(for: item)
                } label: {
                    PortAccessRowView(item: item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func destination(for item: PortAccessItem) -> some View {
        switch item.kind {
        case .navigatorLetter:
            NavigatorLetterView()
        case .provisions:
            ProvisionsView()
        case .mantras:
            MantrasView()
        }
    }
}

private struct PortSummaryCardView: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
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
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct PortInfoCardView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.10))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct PortMomentRowView: View {
    let title: String
    let summary: String
    let expeditionName: String
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text("\(expeditionName) · \(dateText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct PortAccessRowView: View {
    let item: PortAccessItem

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: item.systemImage)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.10))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct PortAccessPlaceholderView: View {
    let item: PortAccessItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: item.systemImage)
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text(item.title)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Este recurso permanece en el Puerto y no pertenece a ninguna Expedicion.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PortView()
}
