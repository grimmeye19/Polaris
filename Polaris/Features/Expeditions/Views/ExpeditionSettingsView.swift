import SwiftData
import SwiftUI

struct ExpeditionSettingsView: View {
    let expedition: Expedition

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ExpeditionSettingsViewModel()
    @State private var showsCloseConfirmation = false
    @State private var saveErrorMessage: String?

    var body: some View {
        Form {
            Section {
                ExpeditionSettingsDetailRow(title: "Estado", value: viewModel.statusText(for: expedition))
                ExpeditionSettingsDetailRow(title: "Momentos", value: "\(expedition.moments.count)")
                ExpeditionSettingsDetailRow(title: "Entradas de Mapa", value: "\(expedition.mapEntries.count)")

                if expedition.status == .closed {
                    ExpeditionSettingsDetailRow(title: "Cierre", value: viewModel.closedAtText(for: expedition))
                }
            } footer: {
                Text(expedition.status == .active ? viewModel.activeMessage : viewModel.closedMessage)
            }

            if expedition.status == .active {
                Section {
                    Button(role: .destructive) {
                        showsCloseConfirmation = true
                    } label: {
                        Label("Cerrar Expedición", systemImage: "lock")
                    }
                    .disabled(viewModel.isSaving)
                } footer: {
                    Text("La Expedición dejará de crecer, pero no se eliminará ningún Momento ni entrada del Mapa.")
                }
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Cerrar Expedición",
            isPresented: $showsCloseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cerrar Expedición", role: .destructive) {
                closeExpedition()
            }

            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Su Historia y su Mapa seguirán disponibles. No se borrará memoria.")
        }
        .alert("No se pudo cerrar", isPresented: showsSaveError) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? "Intenta de nuevo.")
        }
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

    private func closeExpedition() {
        do {
            try viewModel.close(expedition: expedition, in: modelContext)
        } catch {
            saveErrorMessage = "El cierre no pudo conservarse localmente."
        }
    }
}

private struct ExpeditionSettingsDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 16)

            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        ExpeditionSettingsView(
            expedition: Expedition(
                name: "Una etapa importante",
                optionalDescription: "Un viaje observado con calma."
            )
        )
    }
    .modelContainer(PolarisModelContainer.shared)
}
