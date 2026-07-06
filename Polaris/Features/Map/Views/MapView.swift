import SwiftUI

struct MapView: View {
    let expedition: Expedition

    @StateObject private var viewModel = MapViewModel()
    @State private var showsCreateEntry = false
    @State private var selectedEntry: MapEntry?

    var body: some View {
        Group {
            let sections = viewModel.sections(for: expedition)

            if sections.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(sections) { section in
                        Section(section.title) {
                            ForEach(section.entries) { entry in
                                Button {
                                    selectedEntry = entry
                                } label: {
                                    MapEntryRowView(
                                        entry: entry,
                                        typeTitle: viewModel.title(for: entry.type),
                                        updatedAtText: viewModel.formattedUpdatedAt(for: entry)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
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
                    Label("Nueva entrada", systemImage: "plus")
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
                Label("Nueva entrada", systemImage: "plus")
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
}

private struct MapEntryRowView: View {
    let entry: MapEntry
    let typeTitle: String
    let updatedAtText: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
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

                Text(entry.content)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

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
                            type: .detalle,
                            title: "Cafe favorito",
                            content: "Prefiere cafe con leche por la manana."
                        )
                    ]
                }
            }
    }
}
