	import SwiftData
import SwiftUI

struct ExpeditionListView: View {
    @Query(sort: \Expedition.startDate, order: .reverse) private var expeditions: [Expedition]
    @StateObject private var viewModel = ExpeditionListViewModel()
    @State private var showsCreateExpedition = false

    var body: some View {
        NavigationStack {
            Group {
                if expeditions.isEmpty {
                    emptyState
                } else {
                    expeditionList
                }
            }
            .navigationTitle("Expediciones")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ConstellationView(scope: .global)
                    } label: {
                        Label("Constelación", systemImage: "sparkles")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsCreateExpedition = true
                    } label: {
                        Label("Nueva Expedición", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showsCreateExpedition) {
                CreateExpeditionView()
            }
        }
    }

    private var expeditionList: some View {
        List {
            let activeExpeditions = viewModel.activeExpeditions(from: expeditions)
            let closedExpeditions = viewModel.closedExpeditions(from: expeditions)

            if !activeExpeditions.isEmpty {
                Section("Activas") {
                    ForEach(activeExpeditions) { expedition in
                        NavigationLink {
                            ExpeditionDetailView(expedition: expedition)
                        } label: {
                            ExpeditionRowView(
                                expedition: expedition,
                                startDateText: viewModel.formattedStartDate(for: expedition),
                                statusText: viewModel.statusText(for: expedition.status)
                            )
                        }
                    }
                }
            }

            if !closedExpeditions.isEmpty {
                Section("Cerradas") {
                    ForEach(closedExpeditions) { expedition in
                        NavigationLink {
                            ExpeditionDetailView(expedition: expedition)
                        } label: {
                            ExpeditionRowView(
                                expedition: expedition,
                                startDateText: viewModel.formattedStartDate(for: expedition),
                                statusText: viewModel.statusText(for: expedition.status)
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()

            EmptyStateView(
                title: viewModel.emptyTitle,
                message: viewModel.emptyMessage,
                systemImage: "sailboat",
                actionTitle: "Nueva Expedición"
            ) {
                showsCreateExpedition = true
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }
}

private struct ExpeditionRowView: View {
    let expedition: Expedition
    let startDateText: String
    let statusText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(expedition.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer(minLength: 12)

                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(expedition.status == .active ? .blue : .secondary)
            }

            if let description = expedition.optionalDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Text("Inicio: \(startDateText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ExpeditionListView()
        .modelContainer(PolarisModelContainer.shared)
}
