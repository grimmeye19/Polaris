import SwiftData
import SwiftUI

struct MapView: View {
    let expedition: Expedition

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MapViewModel()
    @State private var showsCreateEntry = false
    @State private var selectedEntry: MapEntry?
    @State private var selectedNode: MapTerritoryNode?
    @State private var mode = MapDisplayMode.territory

    var body: some View {
        Group {
            let entries = viewModel.entries(for: expedition)

            if entries.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showsCreateEntry = true
                } label: {
                    Label("Agregar al territorio", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showsCreateEntry) {
            EditMapEntryView(expedition: expedition)
        }
        .sheet(item: $selectedEntry) { entry in
            EditMapEntryView(expedition: expedition, entry: entry)
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Picker("Modo", selection: $mode) {
                ForEach(MapDisplayMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 10)

            switch mode {
            case .territory:
                MapTerritoryView(
                    nodes: viewModel.nodes(for: expedition),
                    selectedNode: $selectedNode,
                    titleForType: viewModel.shortTitle(for:),
                    iconForType: viewModel.icon(for:),
                    dateText: viewModel.formattedCreatedAt(for:)
                )
            case .list:
                listView
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var listView: some View {
        List {
            ForEach(viewModel.sections(for: expedition)) { section in
                Section(section.title) {
                    ForEach(section.entries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            MapEntryRowView(
                                entry: entry,
                                icon: viewModel.icon(for: entry.type),
                                typeTitle: viewModel.shortTitle(for: entry.type),
                                updatedAtText: viewModel.formattedUpdatedAt(for: entry)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        deleteEntries(at: offsets, from: section.entries)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()

            Text(viewModel.emptyTitle)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.emptyMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showsCreateEntry = true
            } label: {
                Label("Agregar al territorio", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }

    private func deleteEntries(at offsets: IndexSet, from entries: [MapEntry]) {
        try? viewModel.deleteEntries(at: offsets, from: entries, in: modelContext)
    }
}

private struct MapEntryRowView: View {
    let entry: MapEntry
    let icon: String
    let typeTitle: String
    let updatedAtText: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(icon)
                .font(.headline)
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 12)

                    Text(typeTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }

                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Actualizado \(updatedAtText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
}

private enum MapDisplayMode: CaseIterable {
    case territory
    case list

    var title: String {
        switch self {
        case .territory:
            "Territorio"
        case .list:
            "Lista"
        }
    }
}

#Preview {
    NavigationStack {
        let expedition = Expedition(
            name: "Una etapa importante",
            optionalDescription: "Un viaje observado con calma."
        )

        MapView(expedition: expedition)
            .onAppear {
                if expedition.mapEntries.isEmpty {
                    expedition.mapEntries = [
                        MapEntry(
                    expedition: expedition,
                    type: .signal,
                    title: "Senal observada",
                    content: "Una pieza que conviene conservar con calma."
                )
            ]
        }
            }
    }
}
