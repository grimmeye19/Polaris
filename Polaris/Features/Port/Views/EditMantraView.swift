import SwiftData
import SwiftUI

struct EditMantraView: View {
    let mantra: Mantra?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MantrasViewModel
    @State private var saveErrorMessage: String?
    @FocusState private var isTextFocused: Bool

    init(mantra: Mantra? = nil) {
        self.mantra = mantra
        _viewModel = StateObject(wrappedValue: MantrasViewModel(mantra: mantra))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Mantra", text: $viewModel.text, axis: .vertical)
                        .lineLimit(2...5)
                        .textInputAutocapitalization(.sentences)
                        .focused($isTextFocused)
                } footer: {
                    Text("Un Mantra debe ser breve, claro y escrito por el Navegante.")
                }
            }
            .navigationTitle(mantra == nil ? "Nuevo Mantra" : "Editar Mantra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveMantra()
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
                isTextFocused = true
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

    private func saveMantra() {
        do {
            try viewModel.save(existing: mantra, in: modelContext)
            dismiss()
        } catch {
            saveErrorMessage = "El Mantra no pudo conservarse localmente."
        }
    }
}

#Preview {
    EditMantraView()
        .modelContainer(PolarisModelContainer.shared)
}
