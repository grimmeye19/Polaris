import SwiftData
import SwiftUI

struct CreateExpeditionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CreateExpeditionViewModel()
    @State private var saveErrorMessage: String?
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $viewModel.name)
                        .textInputAutocapitalization(.sentences)
                        .focused($focusedField, equals: .name)

                    TextField("Descripción opcional", text: $viewModel.optionalDescription, axis: .vertical)
                        .lineLimit(3...5)

                    DatePicker(
                        "Fecha inicial",
                        selection: $viewModel.startDate,
                        displayedComponents: .date
                    )
                } footer: {
                    Text("Una Expedición representa una etapa observada con atención, no una persona ni un resultado.")
                }
            }
            .navigationTitle("Nueva Expedición")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveExpedition()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert("No se pudo guardar", isPresented: showsSaveError) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text(saveErrorMessage ?? "Intenta de nuevo.")
            }
            .onAppear {
                focusedField = .name
            }
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

    private func saveExpedition() {
        guard let expedition = viewModel.makeExpedition() else {
            return
        }

        modelContext.insert(expedition)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveErrorMessage = "La Expedición no pudo conservarse localmente."
        }
    }
}

private enum Field {
    case name
}

#Preview {
    CreateExpeditionView()
        .modelContainer(PolarisModelContainer.shared)
}
