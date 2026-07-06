import SwiftData
import SwiftUI

struct MantrasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mantras: [Mantra]
    @StateObject private var viewModel = MantrasViewModel()
    @State private var showsCreateMantra = false
    @State private var selectedMantra: Mantra?
    @State private var saveErrorMessage: String?

    init() {
        _mantras = Query(sort: \Mantra.updatedAt, order: .reverse)
    }

    var body: some View {
        Group {
            let sortedMantras = viewModel.sortedMantras(from: mantras)

            if sortedMantras.isEmpty {
                emptyState
            } else {
                List {
                    Section {
                        ForEach(sortedMantras) { mantra in
                            Button {
                                selectedMantra = mantra
                            } label: {
                                MantraRowView(
                                    mantra: mantra,
                                    updatedAtText: viewModel.formattedUpdatedAt(for: mantra)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            deleteMantras(at: offsets, from: sortedMantras)
                        }
                    } footer: {
                        Text(viewModel.guidance)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mantras")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showsCreateMantra = true
                } label: {
                    Label("Nuevo Mantra", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showsCreateMantra) {
            EditMantraView()
        }
        .sheet(item: $selectedMantra) { mantra in
            EditMantraView(mantra: mantra)
        }
        .alert("No se pudo guardar", isPresented: showsSaveError) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? "Intenta de nuevo.")
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer()

            Text(viewModel.emptyTitle)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.emptyMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showsCreateMantra = true
            } label: {
                Label("Nuevo Mantra", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 6)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }

    private var showsSaveError: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    saveErrorMessage = nil
                }
            }
        )
    }

    private func deleteMantras(at offsets: IndexSet, from sortedMantras: [Mantra]) {
        for index in offsets {
            modelContext.delete(sortedMantras[index])
        }

        do {
            try modelContext.save()
        } catch {
            saveErrorMessage = "El Mantra no pudo eliminarse localmente."
        }
    }
}

private struct MantraRowView: View {
    let mantra: Mantra
    let updatedAtText: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(mantra.text)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Actualizado \(updatedAtText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

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
        MantrasView()
    }
    .modelContainer(PolarisModelContainer.shared)
}
