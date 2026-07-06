import SwiftData
import SwiftUI

struct EditMapEntryView: View {
    let expedition: Expedition
    let entry: MapEntry?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: EditMapEntryViewModel
    @State private var saveErrorMessage: String?
    @FocusState private var focusedField: Field?

    init(expedition: Expedition, entry: MapEntry? = nil) {
        self.expedition = expedition
        self.entry = entry
        _viewModel = StateObject(wrappedValue: EditMapEntryViewModel(entry: entry))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tipo", selection: $viewModel.type) {
                        ForEach(MapEntryType.allCases, id: \.self) { type in
                            Text(viewModel.title(for: type))
                                .tag(type)
                        }
                    }

                    TextField("Titulo", text: $viewModel.title)
                        .textInputAutocapitalization(.sentences)
                        .focused($focusedField, equals: .title)
                }

                Section {
                    TextField("Descripcion o notas", text: $viewModel.content, axis: .vertical)
                        .lineLimit(4...8)
                } header: {
                    Text("Notas")
                } footer: {
                    Text("Pieza manual del territorio de esta Expedicion. Solo conserva memoria.")
                }
            }
            .navigationTitle(entry == nil ? "Agregar al territorio" : "Editar territorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveEntry()
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

    private func saveEntry() {
        do {
            try viewModel.saveEntry(for: expedition, editing: entry, in: modelContext)
            dismiss()
        } catch {
            saveErrorMessage = "La entrada no pudo conservarse localmente."
        }
    }
}

private enum Field {
    case title
}

#Preview {
    EditMapEntryView(
        expedition: Expedition(name: "Una etapa importante")
    )
    .modelContainer(PolarisModelContainer.shared)
}
