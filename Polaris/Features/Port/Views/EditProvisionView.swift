import SwiftData
import SwiftUI

struct EditProvisionView: View {
    let provision: Provision?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ProvisionsViewModel
    @State private var saveErrorMessage: String?
    @FocusState private var focusedField: Field?

    init(provision: Provision? = nil) {
        self.provision = provision
        _viewModel = StateObject(wrappedValue: ProvisionsViewModel(provision: provision))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Título", text: $viewModel.title)
                        .textInputAutocapitalization(.sentences)
                        .focused($focusedField, equals: .title)

                    TextField("Categoría opcional", text: $viewModel.category)
                        .textInputAutocapitalization(.sentences)
                } footer: {
                    Text("Una Provisión pertenece al Navegante y permanece fuera de cualquier Expedición.")
                }

                Section {
                    TextField("Contenido opcional", text: $viewModel.content, axis: .vertical)
                        .lineLimit(5...10)
                        .focused($focusedField, equals: .content)
                } header: {
                    Text("Recordatorio")
                } footer: {
                    Text("Necesidades, límites, principios o acuerdos contigo mismo.")
                }
            }
            .navigationTitle(provision == nil ? "Nueva Provisión" : "Editar Provisión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveProvision()
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
                focusedField = .title
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

    private func saveProvision() {
        do {
            try viewModel.save(existing: provision, in: modelContext)
            dismiss()
        } catch {
            saveErrorMessage = "La Provisión no pudo conservarse localmente."
        }
    }
}

private enum Field {
    case title
    case content
}

#Preview {
    EditProvisionView()
        .modelContainer(PolarisModelContainer.shared)
}
