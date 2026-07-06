import SwiftData
import SwiftUI

struct EditMomentView: View {
    let moment: Moment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: EditMomentViewModel
    @State private var saveErrorMessage: String?
    @FocusState private var focusedField: Field?

    init(moment: Moment) {
        self.moment = moment
        _viewModel = StateObject(wrappedValue: EditMomentViewModel(moment: moment))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Fecha del Momento",
                        selection: $viewModel.occurredAt,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    TextField("Titulo opcional", text: $viewModel.title)
                        .textInputAutocapitalization(.sentences)
                }

                Section {
                    TextField("Que ocurrio?", text: $viewModel.exteriorText, axis: .vertical)
                        .lineLimit(4...8)
                        .focused($focusedField, equals: .exterior)
                } header: {
                    Text("Exterior")
                } footer: {
                    Text("Hechos observables. Lo que podria recordarse sin convertirlo en conclusion.")
                }

                Section {
                    TextField("Que ocurrio dentro de mi?", text: $viewModel.interiorText, axis: .vertical)
                        .lineLimit(4...8)
                } header: {
                    Text("Interior")
                } footer: {
                    Text("Emociones, sensaciones, reflexiones o interpretaciones del Navegante.")
                }

                Section {
                    TextField("Notas libres", text: $viewModel.freeNotes, axis: .vertical)
                        .lineLimit(3...6)
                } footer: {
                    Text("Detalles que ayudan a recordar sin convertir este registro en una evaluacion.")
                }
            }
            .navigationTitle("Editar Momento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveMoment()
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
                focusedField = .exterior
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

    private func saveMoment() {
        do {
            try viewModel.saveChanges(to: moment, in: modelContext)
            dismiss()
        } catch {
            saveErrorMessage = "Los cambios no pudieron conservarse localmente."
        }
    }
}

private enum Field {
    case exterior
}

#Preview {
    EditMomentView(
        moment: Moment(
            expedition: Expedition(name: "Una etapa importante"),
            occurredAt: Date(),
            title: "Llegada al puerto",
            exteriorText: "Llegamos al puerto antes de que cerrara la tarde.",
            interiorText: "Senti alivio y una calma dificil de explicar.",
            freeNotes: "Recordar la luz sobre el agua."
        )
    )
    .modelContainer(PolarisModelContainer.shared)
}
