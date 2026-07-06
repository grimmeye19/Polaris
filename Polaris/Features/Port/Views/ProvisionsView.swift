import SwiftData
import SwiftUI

struct ProvisionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var provisions: [Provision]
    @StateObject private var viewModel = ProvisionsViewModel()
    @State private var showsCreateProvision = false
    @State private var selectedProvision: Provision?
    @State private var saveErrorMessage: String?

    init() {
        _provisions = Query(sort: \Provision.updatedAt, order: .reverse)
    }

    var body: some View {
        Group {
            let sortedProvisions = viewModel.sortedProvisions(from: provisions)

            if sortedProvisions.isEmpty {
                emptyState
            } else {
                List {
                    Section {
                        ForEach(sortedProvisions) { provision in
                            Button {
                                selectedProvision = provision
                            } label: {
                                ProvisionRowView(
                                    provision: provision,
                                    updatedAtText: viewModel.formattedUpdatedAt(for: provision)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            deleteProvisions(at: offsets, from: sortedProvisions)
                        }
                    } footer: {
                        Text(viewModel.guidance)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Provisiones")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showsCreateProvision = true
                } label: {
                    Label("Nueva Provision", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showsCreateProvision) {
            EditProvisionView()
        }
        .sheet(item: $selectedProvision) { provision in
            EditProvisionView(provision: provision)
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
                showsCreateProvision = true
            } label: {
                Label("Nueva Provision", systemImage: "plus")
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

    private func deleteProvisions(at offsets: IndexSet, from sortedProvisions: [Provision]) {
        for index in offsets {
            modelContext.delete(sortedProvisions[index])
        }

        do {
            try modelContext.save()
        } catch {
            saveErrorMessage = "La Provision no pudo eliminarse localmente."
        }
    }
}

private struct ProvisionRowView: View {
    let provision: Provision
    let updatedAtText: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(provision.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 12)

                    if let category = provision.category, !category.isEmpty {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }

                if let content = provision.content, !content.isEmpty {
                    Text(content)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                }

                Text("Actualizada \(updatedAtText)")
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
        ProvisionsView()
    }
    .modelContainer(PolarisModelContainer.shared)
}
